output "imageBucketName" {
  description = "Name of the private image bucket"
  value       = aws_s3_bucket.images.id
}

output "imageBucketArn" {
  description = "ARN of the private image bucket"
  value       = aws_s3_bucket.images.arn
}

output "instanceProfileName" {
  description = "Name of the EC2 instance profile granting S3 read access"
  value       = local.createRole ? aws_iam_instance_profile.ec2[0].name : var.existingInstanceProfileName
}
