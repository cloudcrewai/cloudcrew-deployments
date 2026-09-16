output "s3_bucket_id" {
  description = "ID (name) of the S3 archive bucket"
  value       = aws_s3_bucket.s3_archive.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 archive bucket"
  value       = aws_s3_bucket.s3_archive.arn
}

output "kms_key_id" {
  description = "ID of the main KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the main KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "Name of the main KMS alias"
  value       = aws_kms_alias.main.name
}

output "kms_alias_arn" {
  description = "ARN of the main KMS alias"
  value       = aws_kms_alias.main.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB aggregates table"
  value       = aws_dynamodb_table.dynamodb_aggregates.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB aggregates table"
  value       = aws_dynamodb_table.dynamodb_aggregates.arn
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis data stream"
  value       = aws_kinesis_stream.kinesis_data_stream.name
}

output "kinesis_stream_arn" {
  description = "ARN of the Kinesis data stream"
  value       = aws_kinesis_stream.kinesis_data_stream.arn
}
