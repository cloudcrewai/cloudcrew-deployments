output "s3_bucket_id" {
  description = "ID of the primary S3 training data bucket."
  value       = aws_s3_bucket.s3_training_data.id
}

output "s3_bucket_arn" {
  description = "ARN of the primary S3 training data bucket."
  value       = aws_s3_bucket.s3_training_data.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_name" {
  description = "The name of the KMS alias for S3 encryption."
  value       = aws_kms_alias.s3.name
}

output "kms_s3_alias_arn" {
  description = "The ARN of the KMS alias for S3 encryption."
  value       = aws_kms_alias.s3.arn
}

output "s3_access_logs_bucket_id" {
  description = "ID of the S3 bucket for access logs."
  value       = aws_s3_bucket.s3_access_logs.id
}

output "s3_access_logs_bucket_arn" {
  description = "ARN of the S3 bucket for access logs."
  value       = aws_s3_bucket.s3_access_logs.arn
}

output "s3_training_data_bucket_id" {
  description = "ID of the S3 bucket for training data."
  value       = aws_s3_bucket.s3_training_data.id
}

output "s3_training_data_bucket_arn" {
  description = "ARN of the S3 bucket for training data."
  value       = aws_s3_bucket.s3_training_data.arn
}

output "s3_model_artifacts_bucket_id" {
  description = "ID of the S3 bucket for model artifacts."
  value       = aws_s3_bucket.s3_model_artifacts.id
}

output "s3_model_artifacts_bucket_arn" {
  description = "ARN of the S3 bucket for model artifacts."
  value       = aws_s3_bucket.s3_model_artifacts.arn
}
