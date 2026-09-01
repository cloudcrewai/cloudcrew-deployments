output "db_endpoint" {
  description = "The connection endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS Aurora cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
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
  description = "The ID of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 bucket encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "iam_rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "iam_cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "iam_config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "alb_logs_bucket_id" {
  description = "The ID of the S3 bucket used for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket used for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "config_logs_bucket_id" {
  description = "The ID of the S3 bucket used for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket used for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "vpc_endpoint_logs_id" {
  description = "The ID of the VPC endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_kms_id" {
  description = "The ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the VPC endpoint for S3."
  value       = aws_vpc_endpoint.s3.id
}

output "rds_cluster_id" {
  description = "The ID of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail trail."
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The AWS Account ID where Security Hub is enabled."
  value       = data.aws_caller_identity.current.account_id
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
