variable "groupName" {
  type        = string
  description = "Group identifier used in resource names"
}

variable "environment" {
  type        = string
  description = "Environment name (Dev, Staging, Prod)"
}

variable "vpcId" {
  type        = string
  description = "VPC in which the security groups are created"
}

variable "sshAllowedCidr" {
  type        = string
  description = "CIDR permitted to SSH into the bastion (restrict to your IP)"
  default     = "0.0.0.0/0"
}

variable "commonTags" {
  type        = map(string)
  default     = {}
}
