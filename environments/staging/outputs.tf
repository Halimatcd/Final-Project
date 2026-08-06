output "websiteUrl" {
  description = "Public URL of the static website (ALB DNS name)"
  value       = "http://${module.alb.albDnsName}"
}

output "albDnsName" {
  description = "ALB DNS name"
  value       = module.alb.albDnsName
}

output "vpcId" {
  description = "VPC ID"
  value       = module.networking.vpcId
}

output "asgName" {
  description = "Auto Scaling Group name"
  value       = module.compute.asgName
}

output "bastionPublicIp" {
  description = "Bastion public IP"
  value       = module.compute.bastionPublicIp
}

output "imageBucketName" {
  description = "Private image bucket name"
  value       = module.s3_iam.imageBucketName
}
