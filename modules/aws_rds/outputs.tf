output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_identifier
}

output "db_instance_address" {
  description = "RDS endpoint address (hostname)"
  value       = module.rds.db_instance_address
}

output "db_instance_endpoint" {
  description = "RDS endpoint (hostname:port)"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
}

# Only present when manage_master_user_password = true
output "db_instance_master_user_secret_arn" {
  description = "Secrets Manager ARN for the master user password"
  value       = try(module.rds.db_instance_master_user_secret_arn, null)
}
