output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC."
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

output "database_subnet_ids" {
  description = "List of IDs of the database subnets."
  value       = aws_subnet.database[*].id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.name
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs."
  value       = aws_kms_key.logs.id
}

output "kms_logs_alias_name" {
  description = "The alias name for the KMS key used for CloudWatch Logs."
  value       = aws_kms_alias.logs.name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role used for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "vpce_interface_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints."
  value       = aws_security_group.vpce_interface.id
}

output "vpce_s3_id" {
  description = "The ID of the S3 Gateway VPC Endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "vpce_ecr_dkr_id" {
  description = "The ID of the ECR Docker Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "vpce_kms_id" {
  description = "The ID of the KMS Interface VPC Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "vpce_ecr_api_id" {
  description = "The ID of the ECR API Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_api.id
}

output "vpce_secrets_manager_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint."
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "vpce_cloudwatch_logs_id" {
  description = "The ID of the CloudWatch Logs Interface VPC Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}
