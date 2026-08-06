############################################
# Remote state backend for the Prod environment.
############################################

terraform {
  backend "s3" {
    bucket       = "hoaminu-prod-tfstate-527581453529"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
