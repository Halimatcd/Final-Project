############################################
# Security Groups module
# Three tiers: ALB, Web (private), Bastion.
# Web only accepts HTTP from the ALB and SSH
# from the bastion -> least-privilege.
############################################

locals {
  namePrefix = "${var.groupName}-${var.environment}"
}

# ---------- ALB security group ----------
resource "aws_security_group" "alb" {
  name        = "${local.namePrefix}-AlbSg"
  description = "Allow inbound HTTP from the internet to the ALB"
  vpc_id      = var.vpcId

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-AlbSg"
  })
}

# ---------- Bastion security group ----------
resource "aws_security_group" "bastion" {
  name        = "${local.namePrefix}-BastionSg"
  description = "Allow SSH to the bastion host"
  vpc_id      = var.vpcId

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sshAllowedCidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-BastionSg"
  })
}

# ---------- Web tier security group ----------
resource "aws_security_group" "web" {
  name        = "${local.namePrefix}-WebSg"
  description = "Allow HTTP from ALB and SSH from bastion"
  vpc_id      = var.vpcId

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "All outbound (updates, S3 via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-WebSg"
  })
}
