output "db_endpoint" {
  description = "The connection endpoint for the RDS cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the RDS cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret for the master user password."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}

output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket for ALB logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "rds_cluster_id" {
  description = "The ID of the RDS cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_identifier" {
  description = "The identifier of the RDS cluster."
  value       = aws_rds_cluster.main.cluster_identifier
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_name" {
  description = "The name of the KMS alias for RDS encryption."
  value       = aws_kms_alias.rds.name
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_name" {
  description = "The name of the KMS alias for S3 encryption."
  value       = aws_kms_alias.s3.name
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs encryption."
  value       = aws_kms_alias.logs.name
}

output "alb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "rds_monitoring_iam_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}
