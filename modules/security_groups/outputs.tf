output "albSgId" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "webSgId" {
  description = "Security group ID for the web tier"
  value       = aws_security_group.web.id
}

output "bastionSgId" {
  description = "Security group ID for the bastion host"
  value       = aws_security_group.bastion.id
}
