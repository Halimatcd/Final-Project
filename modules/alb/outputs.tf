output "albArn" {
  description = "ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "albDnsName" {
  description = "Public DNS name used to reach the website"
  value       = aws_lb.this.dns_name
}

output "targetGroupArn" {
  description = "ARN of the web target group (attached to the ASG)"
  value       = aws_lb_target_group.web.arn
}
