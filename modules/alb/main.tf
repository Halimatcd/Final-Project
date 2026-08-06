############################################
# ALB module
# Application Load Balancer in the public
# subnets, a target group for the web tier,
# and an HTTP listener on port 80.
############################################

locals {
  namePrefix = "${var.groupName}-${var.environment}"
}

resource "aws_lb" "this" {
  name               = lower("${var.groupName}-${var.environment}-alb")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.albSgId]
  subnets            = var.publicSubnetIds

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Alb"
  })
}

resource "aws_lb_target_group" "web" {
  name     = lower("${var.groupName}-${var.environment}-tg")
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcId

  health_check {
    enabled             = true
    path                = var.healthCheckPath
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-Tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(var.commonTags, {
    Name = "${local.namePrefix}-HttpListener"
  })
}
