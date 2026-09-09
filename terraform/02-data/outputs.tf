output "s3_bucket_id" {
  description = "ID of the primary S3 training data bucket."
  value       = aws_s3_bucket.s3_training_data.id
}

output "s3_bucket_arn" {
  description = "ARN of the primary S3 training data bucket."
  value       = aws_s3_bucket.s3_training_data.arn
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
  description = "ID of the S3 bucket for ML training data."
  value       = aws_s3_bucket.s3_training_data.id
}

output "s3_training_data_bucket_arn" {
  description = "ARN of the S3 bucket for ML training data."
  value       = aws_s3_bucket.s3_training_data.arn
}

output "s3_model_artifacts_bucket_id" {
  description = "ID of the S3 bucket for ML model artifacts."
  value       = aws_s3_bucket.s3_model_artifacts.id
}

output "s3_model_artifacts_bucket_arn" {
  description = "ARN of the S3 bucket for ML model artifacts."
  value       = aws_s3_bucket.s3_model_artifacts.arn
}

output "s3_data_kms_key_id" {
  description = "KMS Key ID for S3 data encryption."
  value       = aws_kms_key.s3_data.key_id
}

output "s3_data_kms_key_arn" {
  description = "KMS Key ARN for S3 data encryption."
  value       = aws_kms_key.s3_data.arn
}

output "s3_access_logs_kms_key_id" {
  description = "KMS Key ID for S3 access logs encryption."
  value       = aws_kms_key.s3_access_logs.key_id
}

output "s3_access_logs_kms_key_arn" {
  description = "KMS Key ARN for S3 access logs encryption."
  value       = aws_kms_key.s3_access_logs.arn
}
