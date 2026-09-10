output "db_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port for the RDS PostgreSQL instance."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS instance."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
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
  description = "The ID of the S3 bucket for application assets."
  value       = aws_s3_bucket.app_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for application assets."
  value       = aws_s3_bucket.app_assets.arn
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_secrets_key_id" {
  description = "The ID of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets.key_id
}

output "kms_secrets_key_arn" {
  description = "The ARN of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets.arn
}

output "kms_backup_key_id" {
  description = "The ID of the KMS key for AWS Backup encryption."
  value       = aws_kms_key.backup.key_id
}

output "kms_backup_key_arn" {
  description = "The ARN of the KMS key for AWS Backup encryption."
  value       = aws_kms_key.backup.arn
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS database."
  value       = aws_security_group.db.id
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache Redis."
  value       = aws_security_group.elasticache.id
}

output "rds_instance_identifier" {
  description = "The identifier of the RDS PostgreSQL instance."
  value       = aws_db_instance.main.identifier
}

output "rds_instance_arn" {
  description = "The ARN of the RDS PostgreSQL instance."
  value       = aws_db_instance.main.arn
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret for general database credentials (not the master user secret managed by RDS)."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "s3_access_logs_bucket_id" {
  description = "The ID of the S3 bucket for S3 access logs."
  value       = aws_s3_bucket.s3_access_logs.id
}

output "s3_access_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for S3 access logs."
  value       = aws_s3_bucket.s3_access_logs.arn
}

output "s3_alb_logs_bucket_id" {
  description = "The ID of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "s3_alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "s3_cloudtrail_logs_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "s3_config_bucket_id" {
  description = "The ID of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.id
}

output "s3_config_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.arn
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "logs_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the VPC gateway endpoint for S3."
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_vpc_endpoint_id" {
  description = "The ID of the VPC gateway endpoint for DynamoDB."
  value       = aws_vpc_endpoint.dynamodb.id
}

output "rds_log_group_name" {
  description = "The name of the CloudWatch Log Group for RDS."
  value       = aws_cloudwatch_log_group.rds.name
}

output "elasticache_log_group_name" {
  description = "The name of the CloudWatch Log Group for ElastiCache."
  value       = aws_cloudwatch_log_group.elasticache.name
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}
