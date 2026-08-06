############################################
# Remote state backend for the Dev environment.
# The bucket is created by scripts/bootstrap-state-buckets.sh
# BEFORE running `terraform init`.
############################################

terraform {
  backend "s3" {
    bucket       = "hoaminu-dev-tfstate-527581453529"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
