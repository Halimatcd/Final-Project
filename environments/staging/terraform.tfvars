############################################
# Staging environment values
# VPC 10.200.0.0/16 | 3 web servers | t3.small
############################################

region      = "us-east-1"
groupName   = "Hoaminu"
environment = "Staging"

vpcCidr           = "10.200.0.0/16"
availabilityZones = ["us-east-1b", "us-east-1c", "us-east-1d"]

# Each subnet is a /24 = 256 IP addresses
publicSubnetCidrs  = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
privateSubnetCidrs = ["10.200.11.0/24", "10.200.12.0/24", "10.200.13.0/24"]

instanceType    = "t3.small"
minSize         = 3
desiredCapacity = 3
maxSize         = 4

imageBucketName = "hoaminu-staging-images-527581453529"
imageObjectKey  = "images/site-image.jpg"

teamMembers = "Halimat"

existingInstanceProfileName = "LabInstanceProfile"

keyName        = ""
sshAllowedCidr = "0.0.0.0/0"
