variable "name"            { type = string }                 # ALB name
variable "vpc_id"          { type = string }
variable "subnets"         { type = list(string) }           # public subnets
variable "security_groups" { type = list(string) }

variable "app_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

# Leave empty for HTTP-only. If set, we add HTTPS and redirect HTTP->HTTPS.
variable "certificate_arn" {
  type    = string
  default = ""
}

# Single instance to register (you can expand this later)
variable "instance_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
