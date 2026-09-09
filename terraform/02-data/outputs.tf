output "db_endpoint" {
  description = "The connection endpoint for the Aurora cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the Aurora cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS Aurora cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "aurora_cluster_arn" {
  description = "The ARN of the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.arn
}

output "aurora_cluster_reader_endpoint" {
  description = "The reader endpoint for the Aurora cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "rds_proxy_endpoint" {
  description = "The endpoint for the RDS Proxy."
  value       = aws_db_proxy.main.endpoint
}

output "rds_proxy_arn" {
  description = "The ARN of the RDS Proxy."
  value       = aws_db_proxy.main.arn
}

output "kms_general_key_arn" {
  description = "The ARN of the general-purpose KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_backup_key_arn" {
  description = "The ARN of the KMS key for AWS Backup encryption."
  value       = aws_kms_key.backup.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "db_proxy_role_arn" {
  description = "The ARN of the IAM role for the RDS Proxy."
  value       = aws_iam_role.db_proxy.arn
}

output "aurora_iam_auth_role_arn" {
  description = "The ARN of the IAM role for Aurora IAM database authentication."
  value       = aws_iam_role.aurora_iam_auth.arn
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The AWS account ID where Security Hub is enabled."
  value       = data.aws_caller_identity.current.account_id
}

output "db_proxy_security_group_id" {
  description = "The ID of the security group for the RDS Proxy."
  value       = aws_security_group.db_proxy.id
}

output "vpc_endpoint_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints."
  value       = aws_security_group.vpc_endpoint.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager VPC endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS VPC endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs VPC endpoint."
  value       = aws_vpc_endpoint.logs.id
}
