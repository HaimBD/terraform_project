data "aws_availability_zones" "available" {
  state = "available"
}

# Pick only as many AZs as we have subnets for
locals {
  az_count = max(
    length(var.vpc_public_subnets),
    length(var.vpc_private_subnets)
  )
  azs = slice(data.aws_availability_zones.available.names, 0, local.az_count)
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name             = var.vpc_name
  cidr             = var.vpc_cidr
  azs              = local.azs
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  public_subnet_names  = [for i in range(length(var.vpc_public_subnets))  : "public-subnet-${i + 1}"]
  private_subnet_names = [for i in range(length(var.vpc_private_subnets)) : "private-subnet-${i + 1}"]

  enable_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  single_nat_gateway     = var.single_nat_gateway

  enable_vpn_gateway = var.enable_vpn_gateway
  tags               = var.tags
}