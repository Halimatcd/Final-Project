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
  description = "VPC in which the ALB and target group live"
}

variable "publicSubnetIds" {
  type        = list(string)
  description = "Public subnets the ALB is attached to"
}

variable "albSgId" {
  type        = string
  description = "Security group for the ALB"
}

variable "healthCheckPath" {
  type        = string
  description = "Path used for target group health checks"
  default     = "/"
}

variable "commonTags" {
  type        = map(string)
  default     = {}
}
