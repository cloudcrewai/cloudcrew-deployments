output "kms_dynamodb_key_id" {
  description = "The ID of the KMS key used for DynamoDB encryption."
  value       = aws_kms_key.dynamodb.id
}

output "kms_dynamodb_key_arn" {
  description = "The ARN of the KMS key used for DynamoDB encryption."
  value       = aws_kms_key.dynamodb.arn
}

output "kms_dynamodb_alias_name" {
  description = "The name of the KMS alias for the DynamoDB encryption key."
  value       = aws_kms_alias.dynamodb.name
}

output "kms_dynamodb_alias_arn" {
  description = "The ARN of the KMS alias for the DynamoDB encryption key."
  value       = aws_kms_alias.dynamodb.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.main.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.main.arn
}

output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table (same as name)."
  value       = aws_dynamodb_table.main.id
}
