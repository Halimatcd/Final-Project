############################################
# Networking module
# VPC, public/private subnets across 3 AZs,
# Internet Gateway, single NAT Gateway,
# and route tables.
############################################

locals {
  namePrefix = "${var.groupName}-${var.environment}"
}

# ---------- VPC ----------
resource "aws_vpc" "this" {
  cidr_block           = var.vpcCidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Vpc"
  })
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Igw"
  })
}

# ---------- Public subnets ----------
resource "aws_subnet" "public" {
  count                   = length(var.publicSubnetCidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.publicSubnetCidrs[count.index]
  availability_zone       = var.availabilityZones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-PublicSn${count.index + 1}"
    Tier = "Public"
  })
}

# ---------- Private subnets ----------
resource "aws_subnet" "private" {
  count             = length(var.privateSubnetCidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.privateSubnetCidrs[count.index]
  availability_zone = var.availabilityZones[count.index]

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-PrivateSn${count.index + 1}"
    Tier = "Private"
  })
}

# ---------- NAT Gateway (single, cost-optimised) ----------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-NatEip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-NatGw"
  })

  depends_on = [aws_internet_gateway.this]
}

# ---------- Public route table ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-PublicRt"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------- Private route table ----------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-PrivateRt"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
