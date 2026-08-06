############################################
# S3 + IAM module
# Private image bucket (no public access) and
# an IAM role / instance profile that lets the
# EC2 web servers read objects from it.
############################################

locals {
  namePrefix = "${var.groupName}-${var.environment}"

  # When an existing instance profile is supplied (e.g. AWS Academy's
  # "LabInstanceProfile"), skip creating IAM resources - Learner Lab
  # accounts are not permitted to create roles.
  createRole = var.existingInstanceProfileName == ""
}

# ---------- Private image bucket ----------
resource "aws_s3_bucket" "images" {
  bucket = var.imageBucketName

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-ImagesBucket"
  })
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------- IAM role for EC2 (only when not using an existing profile) ----------
data "aws_iam_policy_document" "assumeRole" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  count              = local.createRole ? 1 : 0
  name               = "${local.namePrefix}-Ec2S3ReadRole"
  assume_role_policy = data.aws_iam_policy_document.assumeRole.json

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Ec2S3ReadRole"
  })
}

# Read-only access scoped to this bucket only
data "aws_iam_policy_document" "s3Read" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.images.arn]
  }
  statement {
    sid       = "GetObjects"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
}

resource "aws_iam_role_policy" "s3Read" {
  count  = local.createRole ? 1 : 0
  name   = "${local.namePrefix}-S3ReadPolicy"
  role   = aws_iam_role.ec2[0].id
  policy = data.aws_iam_policy_document.s3Read.json
}

# Allow Session Manager access without SSH keys
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = local.createRole ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  count = local.createRole ? 1 : 0
  name  = "${local.namePrefix}-Ec2InstanceProfile"
  role  = aws_iam_role.ec2[0].name

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Ec2InstanceProfile"
  })
}
