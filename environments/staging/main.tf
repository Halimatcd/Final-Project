############################################
# Dev environment root configuration.
# Wires the reusable modules together.
# The file is identical across environments;
# only backend.tf and terraform.tfvars differ.
############################################

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.commonTags
  }
}

locals {
  commonTags = {
    Project     = "ACS730-FinalProject"
    Group       = var.groupName
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "s3_iam" {
  source                      = "../../modules/s3_iam"
  groupName                   = var.groupName
  environment                 = var.environment
  imageBucketName             = var.imageBucketName
  existingInstanceProfileName = var.existingInstanceProfileName
  commonTags                  = local.commonTags
}

module "networking" {
  source             = "../../modules/networking"
  groupName          = var.groupName
  environment        = var.environment
  vpcCidr            = var.vpcCidr
  availabilityZones  = var.availabilityZones
  publicSubnetCidrs  = var.publicSubnetCidrs
  privateSubnetCidrs = var.privateSubnetCidrs
  commonTags         = local.commonTags
}

module "security_groups" {
  source         = "../../modules/security_groups"
  groupName      = var.groupName
  environment    = var.environment
  vpcId          = module.networking.vpcId
  sshAllowedCidr = var.sshAllowedCidr
  commonTags     = local.commonTags
}

module "alb" {
  source          = "../../modules/alb"
  groupName       = var.groupName
  environment     = var.environment
  vpcId           = module.networking.vpcId
  publicSubnetIds = module.networking.publicSubnetIds
  albSgId         = module.security_groups.albSgId
  commonTags      = local.commonTags
}

module "compute" {
  source              = "../../modules/compute"
  groupName           = var.groupName
  environment         = var.environment
  instanceType        = var.instanceType
  keyName             = var.keyName
  webSgId             = module.security_groups.webSgId
  bastionSgId         = module.security_groups.bastionSgId
  instanceProfileName = module.s3_iam.instanceProfileName
  publicSubnetIds     = module.networking.publicSubnetIds
  privateSubnetIds    = module.networking.privateSubnetIds
  targetGroupArn      = module.alb.targetGroupArn
  imageBucketName     = module.s3_iam.imageBucketName
  imageObjectKey      = var.imageObjectKey
  teamMembers         = var.teamMembers
  minSize             = var.minSize
  maxSize             = var.maxSize
  desiredCapacity     = var.desiredCapacity
  commonTags          = local.commonTags
}
