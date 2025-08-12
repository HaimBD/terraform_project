locals {
  http_forward_map = length(var.certificate_arn) == 0 ? {
    http = {
      port     = 80
      protocol = "HTTP"
      forward  = { target_group_key = "app" }
    }
  } : {}

  http_redirect_map = length(var.certificate_arn) > 0 ? {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  } : {}

  https_map = length(var.certificate_arn) > 0 ? {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.certificate_arn
      forward         = { target_group_key = "app" }
    }
  } : {}

  listeners = merge(local.http_forward_map, local.http_redirect_map, local.https_map)
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.17.0"

  name               = var.name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets
  enable_deletion_protection = false
  security_groups    = var.security_groups
  tags               = var.tags

  target_groups = {
    app = {
      name              = "${var.name}-tg"
      protocol          = "HTTP"
      port              = var.app_port
      target_type       = "instance"
      vpc_id            = var.vpc_id
      create_attachment = false
      health_check = {
        path = var.health_check_path
      }
    }
  }

  listeners = local.listeners
}
