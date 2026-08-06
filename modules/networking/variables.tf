variable "groupName" {
  description = "Group identifier used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (Dev, Staging, Prod)"
  type        = string
}

variable "vpcCidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availabilityZones" {
  description = "List of AZs to spread subnets across (3 expected)"
  type        = list(string)
}

variable "publicSubnetCidrs" {
  description = "CIDR blocks for the public subnets (one per AZ, each /24 = 256 IPs)"
  type        = list(string)
}

variable "privateSubnetCidrs" {
  description = "CIDR blocks for the private subnets (one per AZ, each /24 = 256 IPs)"
  type        = list(string)
}

variable "commonTags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default     = {}
}
