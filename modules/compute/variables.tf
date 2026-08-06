variable "groupName" {
  type        = string
  description = "Group identifier used in resource names"
}

variable "environment" {
  type        = string
  description = "Environment name (Dev, Staging, Prod)"
}

variable "instanceType" {
  type        = string
  description = "EC2 instance type for the web tier (e.g. t3.micro)"
}

variable "amiId" {
  type        = string
  description = "AMI ID for the web servers. If empty, latest Amazon Linux 2 is used."
  default     = ""
}

variable "keyName" {
  type        = string
  description = "Existing EC2 key pair name for SSH (leave empty to disable SSH key)"
  default     = ""
}

variable "webSgId" {
  type        = string
  description = "Security group for the web tier"
}

variable "bastionSgId" {
  type        = string
  description = "Security group for the bastion host"
}

variable "instanceProfileName" {
  type        = string
  description = "Instance profile granting S3 read access"
}

variable "publicSubnetIds" {
  type        = list(string)
  description = "Public subnets (bastion is placed in the first one)"
}

variable "privateSubnetIds" {
  type        = list(string)
  description = "Private subnets where the ASG launches web servers"
}

variable "targetGroupArn" {
  type        = string
  description = "Target group the ASG registers instances with"
}

variable "imageBucketName" {
  type        = string
  description = "Bucket the web servers download the site image from"
}

variable "imageObjectKey" {
  type        = string
  description = "Object key of the image inside the bucket"
  default     = "images/site-image.jpg"
}

variable "teamMembers" {
  type        = string
  description = "Comma-separated team member names displayed on the webpage"
  default     = "Team Member 1, Team Member 2, Team Member 3"
}

variable "minSize" {
  type        = number
  description = "Minimum number of instances in the ASG"
}

variable "maxSize" {
  type        = number
  description = "Maximum number of instances in the ASG"
  default     = 4
}

variable "desiredCapacity" {
  type        = number
  description = "Desired number of instances in the ASG"
}

variable "enableBastion" {
  type        = bool
  description = "Whether to create a bastion host"
  default     = true
}

variable "commonTags" {
  type        = map(string)
  default     = {}
}
