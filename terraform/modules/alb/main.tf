resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Security group for ${var.name} application load balancer."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.internal ? [] : [1]

    content {
      description = "HTTP from the internet."
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = var.internal || var.certificate_arn == null ? [] : [1]

    content {
      description = "HTTPS from the internet."
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = var.internal ? var.allowed_ingress_security_group_ids : []

    content {
      description              = "HTTP from allowed security groups."
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      security_groups          = [ingress.value]
    }
  }

  egress {
    description = "Allow outbound traffic to targets."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  dynamic "access_logs" {
    for_each = var.logs_bucket_name != null ? [1] : []

    content {
      bucket  = var.logs_bucket_name
      prefix  = "alb"
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = !var.internal && var.certificate_arn != null ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = !var.internal && var.certificate_arn != null ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.internal || var.certificate_arn == null ? [1] : []

      content {
        target_group {
          arn = aws_lb_target_group.this.arn
        }
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count = !var.internal && var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.this.arn
      }
    }
  }
}
