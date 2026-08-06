variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "groupName" {
  type        = string
  description = "Group identifier used in resource names"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "Prod"
}

variable "vpcCidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availabilityZones" {
  type        = list(string)
  description = "Three AZs to spread subnets across"
}

variable "publicSubnetCidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ, /24)"
}

variable "privateSubnetCidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ, /24)"
}

variable "instanceType" {
  type        = string
  description = "Web tier instance type"
}

variable "minSize" {
  type        = number
  description = "Minimum ASG size"
}

variable "desiredCapacity" {
  type        = number
  description = "Desired ASG size (number of web servers for this environment)"
}

variable "maxSize" {
  type        = number
  description = "Maximum ASG size"
  default     = 4
}

variable "imageBucketName" {
  type        = string
  description = "Globally-unique name of the private image bucket"
}

variable "imageObjectKey" {
  type        = string
  description = "Object key of the site image inside the bucket"
  default     = "images/site-image.jpg"
}

variable "teamMembers" {
  type        = string
  description = "Comma-separated team member names shown on the webpage"
}

variable "keyName" {
  type        = string
  description = "Existing EC2 key pair name (optional)"
  default     = ""
}

variable "sshAllowedCidr" {
  type        = string
  description = "CIDR permitted to SSH into the bastion"
  default     = "0.0.0.0/0"
}

variable "existingInstanceProfileName" {
  type        = string
  description = "Pre-existing instance profile to attach to EC2 (AWS Academy: LabInstanceProfile). Empty = create a new role."
  default     = "LabInstanceProfile"
}
