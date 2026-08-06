############################################
# Prod environment values
# VPC 10.250.0.0/16 | 3 web servers | t3.medium
############################################

region      = "us-east-1"
groupName   = "Hoaminu"
environment = "Prod"

vpcCidr           = "10.250.0.0/16"
availabilityZones = ["us-east-1b", "us-east-1c", "us-east-1d"]

# Each subnet is a /24 = 256 IP addresses
publicSubnetCidrs  = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24"]
privateSubnetCidrs = ["10.250.11.0/24", "10.250.12.0/24", "10.250.13.0/24"]

instanceType    = "t3.medium"
minSize         = 3
desiredCapacity = 3
maxSize         = 4

imageBucketName = "hoaminu-prod-images-527581453529"
imageObjectKey  = "images/site-image.jpg"

teamMembers = "Halimat"

existingInstanceProfileName = "LabInstanceProfile"

keyName        = ""
sshAllowedCidr = "0.0.0.0/0"
