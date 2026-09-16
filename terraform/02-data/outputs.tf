output "dynamodb_kms_key_id" {
  description = "ID of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb.key_id
}

output "dynamodb_kms_key_arn" {
  description = "ARN of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb.arn
}

output "dynamodb_kms_alias_name" {
  description = "Name of the KMS alias for DynamoDB encryption"
  value       = aws_kms_alias.dynamodb.name
}

output "dynamodb_kms_alias_arn" {
  description = "ARN of the KMS alias for DynamoDB encryption"
  value       = aws_kms_alias.dynamodb.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB data table"
  value       = aws_dynamodb_table.data_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB data table"
  value       = aws_dynamodb_table.data_table.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB data table"
  value       = aws_dynamodb_table.data_table.id
}
