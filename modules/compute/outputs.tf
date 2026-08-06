output "asgName" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "launchTemplateId" {
  description = "ID of the launch template"
  value       = aws_launch_template.web.id
}

output "bastionPublicIp" {
  description = "Public IP of the bastion host (if created)"
  value       = var.enableBastion ? aws_instance.bastion[0].public_ip : null
}
