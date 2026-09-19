output "db_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port for the RDS instance."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing RDS credentials."
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
  description = "The ID of the application assets S3 bucket."
  value       = aws_s3_bucket.app_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the application assets S3 bucket."
  value       = aws_s3_bucket.app_assets.arn
}

output "kms_main_key_arn" {
  description = "ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_rds_key_arn" {
  description = "ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "flow_logs_bucket_name" {
  description = "Name of the S3 bucket for VPC Flow Logs."
  value       = aws_s3_bucket.flow_logs.bucket
}

output "app_assets_bucket_name" {
  description = "Name of the S3 bucket for application assets."
  value       = aws_s3_bucket.app_assets.bucket
}

output "cloudtrail_logs_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "config_logs_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "rds_instance_identifier" {
  description = "Identifier of the RDS instance."
  value       = aws_db_instance.main.identifier
}

output "rds_proxy_endpoint" {
  description = "The endpoint for the RDS Proxy."
  value       = aws_db_proxy.main.endpoint
}

output "elasticache_replication_group_id" {
  description = "ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_security_group_id" {
  description = "ID of the security group for ElastiCache Redis."
  value       = aws_security_group.elasticache.id
}

output "backup_vault_name" {
  description = "Name of the primary AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the primary AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "backup_vault_dr_name" {
  description = "Name of the DR AWS Backup vault."
  value       = aws_backup_vault.dr.name
}

output "backup_vault_dr_arn" {
  description = "ARN of the DR AWS Backup vault."
  value       = aws_backup_vault.dr.arn
}

output "secrets_manager_vpce_id" {
  description = "ID of the Secrets Manager VPC Endpoint."
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "secrets_manager_vpce_dns_name" {
  description = "DNS name of the Secrets Manager VPC Endpoint."
  value       = aws_vpc_endpoint.secrets_manager.dns_entry[0].dns_name
}

output "cloudwatch_log_group_rds_name" {
  description = "Name of the CloudWatch Log Group for RDS PostgreSQL logs."
  value       = aws_cloudwatch_log_group.rds.name
}

output "cloudwatch_log_group_elasticache_name" {
  description = "Name of the CloudWatch Log Group for ElastiCache logs."
  value       = aws_cloudwatch_log_group.elasticache.name
}

output "cloudwatch_log_group_cloudtrail_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_config_name" {
  description = "Name of the CloudWatch Log Group for AWS Config logs."
  value       = aws_cloudwatch_log_group.config.name
}

output "cloudtrail_trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "ID of the Security Hub account."
  value       = aws_securityhub_account.main.id
}
