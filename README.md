# ACS730 Final Project — Two-Tier Web Application (Terraform)

Modular Terraform that deploys a highly available two-tier static website on AWS in three
environments (Dev, Staging, Prod). Web servers run in an Auto Scaling Group behind an
Application Load Balancer and serve an image pulled from a **private** S3 bucket via an
EC2 IAM role.

## Architecture (per environment)

- One VPC spanning three Availability Zones (`us-east-1b/c/d`).
- Three public subnets (ALB + NAT + bastion) and three private subnets (web servers). Every subnet is a `/24` (256 IPs).
- Internet Gateway for public egress, a single NAT Gateway for private egress.
- Application Load Balancer → HTTP:80 listener → target group → ASG.
- Auto Scaling Group (min per env, **max 4**) with CPU scaling policies: **scale out > 10% CPU, scale in < 5% CPU**.
- Private S3 bucket (public access blocked) for the site image; EC2 instances read it through an IAM instance profile.
- Bastion host in a public subnet for administration.

| Environment | VPC CIDR         | Web servers (desired) | Instance type |
|-------------|------------------|-----------------------|---------------|
| Dev         | `10.100.0.0/16`  | 2                     | `t3.micro`    |
| Staging     | `10.200.0.0/16`  | 3                     | `t3.small`    |
| Prod        | `10.250.0.0/16`  | 3                     | `t3.medium`   |

## Repository layout

```
modules/
  networking/       VPC, subnets, IGW, NAT, route tables
  security_groups/  ALB, web, bastion SGs (least privilege)
  alb/              ALB, target group, HTTP listener
  compute/          launch template, ASG, scaling policies, bastion
  s3_iam/           private image bucket + EC2 IAM role/instance profile
environments/
  dev/  staging/  prod/    root configs (identical main.tf; backend.tf + tfvars differ)
scripts/
  bootstrap-state-buckets.sh   creates the remote-state buckets
.github/workflows/
  security-scan.yml            tflint + trivy on push→staging and PR→prod
```

## Prerequisites

1. **AWS account** with credentials configured locally (`aws configure`) and permission to create VPC, EC2, ELB, ASG, IAM, and S3 resources.
2. **Terraform >= 1.10** (the S3 backend uses native `use_lockfile` state locking).
3. **Remote-state S3 buckets** — one per environment — must exist **before** `terraform init`. Edit the bucket names in `scripts/bootstrap-state-buckets.sh` and each `environments/<env>/backend.tf` to your own globally-unique names, then run:
   ```bash
   ./scripts/bootstrap-state-buckets.sh
   ```
4. **Site image** — after the first apply creates the image bucket, upload an image manually (the bucket is private; the web servers read it via their IAM role):
   ```bash
   aws s3 cp ./my-image.jpg s3://hoaminu-dev-images-527581453529/images/site-image.jpg
   ```
   The `imageObjectKey` in each `terraform.tfvars` must match the key you upload.

## Before your first push

The CI `fmt -check` step is strict. Run once locally so it passes:
```bash
terraform fmt -recursive
```

## Configure

In each `environments/<env>/terraform.tfvars` set at least:

- `groupName` — set to `Hoaminu` (drives all resource names, CamelCase).
- `teamMembers` — comma-separated names shown on the webpage.
- `imageBucketName` — your unique image bucket name.
- `keyName` *(optional)* — an existing EC2 key pair for SSH via the bastion.

And in each `environments/<env>/backend.tf` set `bucket` to your state bucket name.

## Deploy

Run per environment (example: Dev):

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

On completion Terraform prints the website URL:

```
websiteUrl = "http://<alb-dns-name>"
```

Open it in a browser — refresh a few times to see requests balanced across instances/AZs.
Repeat in `environments/staging` and `environments/prod`.

## Verify high availability

Stop or terminate one web instance in the AWS Console. The ALB health check marks it
unhealthy, the ASG replaces it, and the site stays available on the same URL throughout.

## Cleanup

Destroy per environment (empty the image bucket first, since it has versioning enabled):

```bash
cd environments/dev
aws s3 rm s3://hoaminu-dev-images-527581453529 --recursive
terraform destroy
```

Repeat for staging and prod. The remote-state buckets created by the bootstrap script are
not managed by Terraform; delete them manually if you no longer need the state history.

## Security scanning (GitHub Actions)

`.github/workflows/security-scan.yml` runs on every **push to `staging`** and every
**pull request into `prod`**:

- `terraform fmt -check` — formatting gate.
- `tflint` — Terraform + AWS ruleset lint.
- `trivy` — IaC misconfiguration scan and secret scan (fails on HIGH/CRITICAL).

Enable **branch protection** on `prod` in GitHub (Settings → Branches): require a pull
request, require the security-scan status check to pass, and require review before merge.
