variable "groupName" {
  type        = string
  description = "Group identifier used in resource names"
}

variable "environment" {
  type        = string
  description = "Environment name (Dev, Staging, Prod)"
}

variable "imageBucketName" {
  type        = string
  description = "Globally-unique name of the private S3 bucket that stores website images"
}

variable "existingInstanceProfileName" {
  type        = string
  description = "Pre-existing instance profile to use instead of creating one (e.g. AWS Academy 'LabInstanceProfile'). Leave empty to create a new IAM role/profile."
  default     = ""
}

variable "commonTags" {
  type        = map(string)
  default     = {}
}
