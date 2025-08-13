output "asg_name" {
  value = module.aws_asg.autoscaling_group_name
}

output "rds_identifier" {
  value       = module.rds.db_instance_identifier
  description = "RDS instance identifier (from wrapper)"
}

output "rds_endpoint" {
  value       = module.rds.db_instance_endpoint
  description = "RDS endpoint (host:port)"
}

output "rds_master_user_secret_arn" {
  value       = module.rds.db_instance_master_user_secret_arn
  description = "Secrets Manager secret ARN (may be null if disabled)"
}


