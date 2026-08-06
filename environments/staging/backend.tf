############################################
# Remote state backend for the Staging environment.
############################################

terraform {
  backend "s3" {
    bucket       = "hoaminu-staging-tfstate-527581453529"
    key          = "staging/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
