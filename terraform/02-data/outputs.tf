output "db_endpoint" {
  description = "The connection endpoint for the RDS database instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port for the RDS database instance."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "The port for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.port
}

output "s3_bucket_id" {
  description = "The ID of the main application assets S3 bucket."
  value       = aws_s3_bucket.assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the main application assets S3 bucket."
  value       = aws_s3_bucket.assets.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_arn" {
  description = "The ARN of the KMS alias for RDS encryption."
  value       = aws_kms_alias.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_elasticache_alias_arn" {
  description = "The ARN of the KMS alias for ElastiCache encryption."
  value       = aws_kms_alias.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for general S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_arn" {
  description = "The ARN of the KMS alias for general S3 encryption."
  value       = aws_kms_alias.s3.arn
}

output "kms_s3_alb_logs_key_arn" {
  description = "The ARN of the KMS key used for ALB access logs S3 bucket encryption."
  value       = aws_kms_key.s3_alb_logs.arn
}

output "kms_s3_alb_logs_alias_arn" {
  description = "The ARN of the KMS alias for ALB access logs S3 bucket encryption."
  value       = aws_kms_alias.s3_alb_logs.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_arn" {
  description = "The ARN of the KMS alias for CloudWatch Logs encryption."
  value       = aws_kms_alias.logs.arn
}

output "kms_sns_key_arn" {
  description = "The ARN of the KMS key used for SNS topic encryption."
  value       = aws_kms_key.sns.arn
}

output "kms_sns_alias_arn" {
  description = "The ARN of the KMS alias for SNS topic encryption."
  value       = aws_kms_alias.sns.arn
}

output "kms_secrets_key_arn" {
  description = "The ARN of the KMS key used for Secrets Manager encryption."
  value       = aws_kms_key.secrets.arn
}

output "kms_secrets_alias_arn" {
  description = "The ARN of the KMS alias for Secrets Manager encryption."
  value       = aws_kms_alias.secrets.arn
}

output "iam_rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "iam_flow_logs_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "iam_cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "iam_backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache Redis."
  value       = aws_security_group.elasticache.id
}

output "rds_instance_arn" {
  description = "The ARN of the RDS database instance."
  value       = aws_db_instance.main.arn
}

output "rds_instance_identifier" {
  description = "The identifier of the RDS database instance."
  value       = aws_db_instance.main.identifier
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache subnet group."
  value       = aws_elasticache_subnet_group.main.name
}

output "alb_logs_bucket_id" {
  description = "The ID of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "cloudtrail_logs_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_logs_bucket_id" {
  description = "The ID of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for general alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_config_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the VPC interface endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the VPC interface endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "logs_vpc_endpoint_id" {
  description = "The ID of the VPC interface endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "db_credentials_secret_id" {
  description = "The ID of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.id
}
