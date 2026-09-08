output "db_endpoint" {
  description = "The connection endpoint for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}

output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "rds_cluster_identifier" {
  description = "The identifier of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.cluster_identifier
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_primary_instance_id" {
  description = "The identifier of the primary RDS Aurora PostgreSQL instance."
  value       = aws_rds_cluster_instance.primary.identifier
}

output "rds_replica_az_b_instance_id" {
  description = "The identifier of the replica RDS Aurora PostgreSQL instance in AZ B."
  value       = aws_rds_cluster_instance.replica_az_b.identifier
}

output "rds_replica_az_c_instance_id" {
  description = "The identifier of the replica RDS Aurora PostgreSQL instance in AZ C."
  value       = aws_rds_cluster_instance.replica_az_c.identifier
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_kms_id" {
  description = "The ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_logs_id" {
  description = "The ID of the VPC endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the VPC gateway endpoint for S3."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of the VPC gateway endpoint for DynamoDB."
  value       = aws_vpc_endpoint.dynamodb.id
}
