module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier     = var.identifier
  engine         = "mysql"
  engine_version = var.engine_version
  family         = "mysql8.0"

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100

  multi_az          = var.multi_az
  storage_encrypted = var.storage_encrypted
  kms_key_id        = length(var.kms_key_id) > 0 ? var.kms_key_id : null
  create_db_option_group = false

  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible

  manage_master_user_password = var.manage_master_user_password
  username                    = var.username
  password                    = var.password
  # master_user_secret_kms_key_id = var.kms_key_id

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = true

  tags = var.tags
}
