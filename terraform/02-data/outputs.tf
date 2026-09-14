output "db_endpoint" {
  description = "The connection endpoint for the primary RDS instance."
  value       = aws_db_instance.rds_primary.address
}

output "db_port" {
  description = "The port for the primary RDS instance."
  value       = aws_db_instance.rds_primary.port
}

output "db_name" {
  description = "The name of the database created in the primary RDS instance."
  value       = aws_db_instance.rds_primary.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret for the primary RDS master user."
  value       = aws_db_instance.rds_primary.master_user_secret[0].secret_arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.elasticache_primary.primary_endpoint_address
}

output "redis_port" {
  description = "The port for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.elasticache_primary.port
}

output "s3_bucket_id" {
  description = "The ID of the main S3 assets bucket."
  value       = aws_s3_bucket.s3_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the main S3 assets bucket."
  value       = aws_s3_bucket.s3_assets.arn
}

output "kms_rds_key_arn" {
  description = "ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "iam_rds_monitoring_role_arn" {
  description = "ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "iam_cloudtrail_role_arn" {
  description = "ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_config_role_arn" {
  description = "ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_config_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "s3_alb_logs_bucket_id" {
  description = "ID of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.s3_alb_logs.id
}

output "s3_cloudtrail_logs_bucket_id" {
  description = "ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_config_logs_bucket_id" {
  description = "ID of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}







output "redis_replica_endpoint" {
  description = "The primary endpoint address for the ElastiCache Redis replica group."
  value       = aws_elasticache_replication_group.elasticache_replica.primary_endpoint_address
}

output "redis_replica_port" {
  description = "The port for the ElastiCache Redis replica group."
  value       = aws_elasticache_replication_group.elasticache_replica.port
}

output "cloudwatch_cloudtrail_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudwatch_config_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for AWS Config."
  value       = aws_cloudwatch_log_group.config.arn
}

output "cloudwatch_alarms_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for general alarms."
  value       = aws_cloudwatch_log_group.alarms.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.main.name
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_kms_id" {
  description = "ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_s3_id" {
  description = "ID of the VPC endpoint for S3."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_logs_id" {
  description = "ID of the VPC endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "elasticache_security_group_id" {
  description = "ID of the security group for ElastiCache."
  value       = aws_security_group.elasticache.id
}
