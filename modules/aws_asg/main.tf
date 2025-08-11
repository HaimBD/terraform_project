module "web_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.5.0"

  name = "${var.resource_alias}-web"

  # Instance config
  min_size         = 1
  desired_capacity = 1
  max_size         = 2
  health_check_type = "ELB"
  vpc_zone_identifier = module.aws_vpc.public_subnets_ids

  # Launch template inside module
  launch_template_name = "${var.resource_alias}-web-lt"
  launch_template_version = "$Latest"

  image_id = data.aws_ssm_parameter.al2.value
  instance_type = var.env == "Staging" ? "t2.micro" : "t3.micro"
  key_name = var.keypair_name

  security_groups = [aws_security_group.ec2_group.id]

  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum -y update
    yum -y install nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from $(hostname)</h1>" > /usr/share/nginx/html/index.html
  EOT
  )

  # ALB Target group attachment
  target_group_arns = [module.aws_alb.app_tg_arn]

  tags = [
    {

      value               = "${var.resource_alias}-web"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.env
      propagate_at_launch = true
    }
  ]
}