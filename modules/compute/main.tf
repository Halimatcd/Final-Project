############################################
# Compute module
# Launch template, Auto Scaling Group across
# the private subnets, CPU-based scaling
# policies, and an optional bastion host.
############################################

locals {
  namePrefix = "${var.groupName}-${var.environment}"
}

# Latest Amazon Linux 2 AMI (used when amiId is not supplied)
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  effectiveAmiId = var.amiId != "" ? var.amiId : data.aws_ami.al2.id

  userData = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    groupName       = var.groupName
    environment     = var.environment
    teamMembers     = var.teamMembers
    imageBucketName = var.imageBucketName
    imageObjectKey  = var.imageObjectKey
  }))
}

# ---------- Launch template ----------
resource "aws_launch_template" "web" {
  name_prefix   = "${local.namePrefix}-Lt-"
  image_id      = local.effectiveAmiId
  instance_type = var.instanceType
  key_name      = var.keyName != "" ? var.keyName : null
  user_data     = local.userData

  iam_instance_profile {
    name = var.instanceProfileName
  }

  vpc_security_group_ids = [var.webSgId]

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.commonTags, {
      Name = "${local.namePrefix}-Web"
    })
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-LaunchTemplate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- Auto Scaling Group ----------
resource "aws_autoscaling_group" "web" {
  name                      = "${local.namePrefix}-Asg"
  min_size                  = var.minSize
  max_size                  = var.maxSize
  desired_capacity          = var.desiredCapacity
  vpc_zone_identifier       = var.privateSubnetIds
  target_group_arns         = [var.targetGroupArn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.namePrefix}-Web"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.commonTags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- Scale-out policy: CPU > 10% ----------
resource "aws_autoscaling_policy" "scaleOut" {
  name                   = "${local.namePrefix}-ScaleOut"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "cpuHigh" {
  alarm_name          = "${local.namePrefix}-CpuHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Scale out when average CPU exceeds 10%"
  alarm_actions       = [aws_autoscaling_policy.scaleOut.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = var.commonTags
}

# ---------- Scale-in policy: CPU < 5% ----------
resource "aws_autoscaling_policy" "scaleIn" {
  name                   = "${local.namePrefix}-ScaleIn"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "cpuLow" {
  alarm_name          = "${local.namePrefix}-CpuLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Scale in when average CPU falls below 5%"
  alarm_actions       = [aws_autoscaling_policy.scaleIn.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = var.commonTags
}

# ---------- Bastion host ----------
resource "aws_instance" "bastion" {
  count                       = var.enableBastion ? 1 : 0
  ami                         = local.effectiveAmiId
  instance_type               = "t3.micro"
  subnet_id                   = var.publicSubnetIds[0]
  vpc_security_group_ids      = [var.bastionSgId]
  key_name                    = var.keyName != "" ? var.keyName : null
  associate_public_ip_address = true
  iam_instance_profile        = var.instanceProfileName

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Bastion"
  })
}
