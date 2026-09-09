output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for logs"
  value       = aws_kms_key.logs.id
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for logs"
  value       = aws_kms_alias.logs.name
}

output "cloudwatch_flow_logs_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_security_group_id" {
  description = "The ID of the security group for VPC Endpoints"
  value       = aws_security_group.vpc_endpoint.id
}

output "default_security_group_id" {
  description = "The ID of the default security group for the VPC"
  value       = aws_default_security_group.default.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}
