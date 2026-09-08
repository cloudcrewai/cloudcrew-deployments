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
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS instance."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "s3_bucket_id" {
  description = "The ID of the primary S3 bucket for PHI documents."
  value       = aws_s3_bucket.phi_documents.id
}

output "s3_bucket_arn" {
  description = "The ARN of the primary S3 bucket for PHI documents."
  value       = aws_s3_bucket.phi_documents.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "phi_documents_bucket_name" {
  description = "The name of the S3 bucket for PHI documents."
  value       = aws_s3_bucket.phi_documents.bucket
}

output "phi_documents_bucket_arn" {
  description = "The ARN of the S3 bucket for PHI documents."
  value       = aws_s3_bucket.phi_documents.arn
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "db_instance_arn" {
  description = "The ARN of the RDS database instance."
  value       = aws_db_instance.main.arn
}

output "db_instance_identifier" {
  description = "The identifier of the RDS database instance."
  value       = aws_db_instance.main.identifier
}

