variable "identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version (e.g., 8.0 or 8.0.36)"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage (GiB)"
  type        = number
  default     = 20
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password"
  type        = string
  default     = "Pa55w.rd"
}

variable "subnet_ids" {
  description = "Exactly two private subnet IDs for Multi-AZ"
  type        = list(string)
  default = [
    # "subnet-12345678",
    # "subnet-87654321"
  ]
  validation {
    condition     = length(var.subnet_ids) == 2
    error_message = "Provide exactly two private subnet IDs (one per AZ) for Multi-AZ."
  }
}

variable "vpc_security_group_ids" {
  description = "RDS Security Group IDs"
  type        = list(string)
  default = [
    # "sg-12345678"
  ]
}

variable "publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "manage_master_user_password" {
  type    = bool
  default = false
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "backup_window" {
  type    = string
  default = "04:00-05:00"
}

variable "maintenance_window" {
  type    = string
  default = "sun:05:00-sun:06:00"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default = {
    Name      = ""
    Env       = ""
    Terraform = "true"
  }
}
