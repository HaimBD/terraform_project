# VPC module for terraform
# module "app_vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 6.0"
#
#   name = "${var.vpc-name}-vpc"
#   cidr = var.vpc_cidr
#
#   azs             = ["us-east-1", "us-east-2", "us-east-3"]
#   private_subnets = var.vpc_private_subnets
#   public_subnets  = var.vpc_public_subnets
#
#   enable_nat_gateway = false
#
#   tags = {
#     Name        = "${var.vpc-name}-vpc"
#     Env         = "prod"
#     Terraform   = true
#   }
# }

# module "app_vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 6.0"
#
#   name             = "${var.resource_alias}-vpc"
#   vpc_cidr_block   = var.vpc_cidr
#   availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
#
#   private_subnets_cidr_blocks = var.vpc_private_subnets
#   public_subnets_cidr_blocks  = var.vpc_public_subnets
#
#   enable_nat_gateway = false
#
#   tags = {
#     Name        = "${var.vpc-name}-vpc"
#     Env         = "prod"
#     Terraform   = true
#   }
# }

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available_azs.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.tags
}