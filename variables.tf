# Used for EC2 creation and configuration in main.tf

variable "env" {
    description = "Variable test for tags"
    type = string
    default = "Staging"
    }
variable "security_group" {
    description = "Security group for test"
    type = string
    default = "SG-WEB"
    }
variable "keypair_name" {
    description  = "Keypair via terraform"
    type = string
    default = "HaimBD-KP#2"
    }

variable "resource_alias" {
    description = "Resource alias for resources"
    type = string
    default = "hbd"
    }
variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16" # or set in tfvars
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "Private subnets CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "Public subnets CIDRs"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

