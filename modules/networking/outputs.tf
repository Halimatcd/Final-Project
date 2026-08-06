output "vpcId" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpcCidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "publicSubnetIds" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "privateSubnetIds" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
