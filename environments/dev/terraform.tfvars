############################################
# Dev environment values
# VPC 10.100.0.0/16 | 2 web servers | t3.micro
############################################

region      = "us-east-1"
groupName   = "Hoaminu"
environment = "Dev"

vpcCidr           = "10.100.0.0/16"
availabilityZones = ["us-east-1b", "us-east-1c", "us-east-1d"]

# Each subnet is a /24 = 256 IP addresses
publicSubnetCidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
privateSubnetCidrs = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]

instanceType    = "t3.micro"
minSize         = 2
desiredCapacity = 2
maxSize         = 4

imageBucketName = "hoaminu-dev-images-527581453529"
imageObjectKey  = "images/site-image.jpg"

teamMembers = "Halimat"

# AWS Academy Learner Lab: use the pre-existing profile (no role creation allowed)
existingInstanceProfileName = "LabInstanceProfile"

keyName        = ""
sshAllowedCidr = "0.0.0.0/0"
