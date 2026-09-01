output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways."
  value       = aws_nat_gateway.main[*].id
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The alias name for the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_alias.logs.name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role used by VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log resource."
  value       = aws_flow_log.main.id
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Gateway Endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.arn
}
