variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "AZ names (e.g., us-east-1a/b/c)"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Create VPN gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Practice-vpc"
  type        = map(string)
  default     = {Name: "hbd-vpc", Env: "Practice"}
}

variable "public_subnet_tags" {
  description = "Map of tags for each public subnet"
  type        = map(map(string))
  default     = {}
}

variable "private_subnet_tags" {
  description = "Map of tags for each private subnet"
  type        = map(map(string))
  default     = {}
}