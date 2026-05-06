module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${local.resource_name}-ingress-alb"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  internal                   = false #if it is true So no public access
  security_groups            = [local.ingress_alb_sg_id]
  create_security_group      = false
  enable_deletion_protection = false # I have disable as it wont allow you to destroy.



  tags = merge(
    var.common_tags,
    var.ingress_alb_tags
  )

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hi, I am from application ALB </h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hi, I am from ALB HTTPS </h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "5.0.0"

  zone_name = var.zone_name

  records = [
    {
      name = "expense-${var.environment}"
      type = "A"
      alias = {
        name    = module.ingress_alb.dns_name
        zone_id = module.ingress_alb.zone_id
      }
      allow_overwrite = true
    }
  ]
}

resource "aws_lb_target_group" "expense" {
  name        = local.resource_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    matcher             = "200-299"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 4
  }
}

resource "aws_lb_listener_rule" "expense" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.expense.arn
      }
    }
  }

  condition {
    host_header {
      values = ["expense-${var.environment}.${var.zone_name}"] #expense-development.chaitanyaproject.online
    }
  }
}



