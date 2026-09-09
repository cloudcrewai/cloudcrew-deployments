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

output "app_security_group_id" {
  description = "ID of the security group for private compute instances (e.g., SageMaker)"
  value       = aws_security_group.private_compute.id
}

output "db_security_group_id" {
  description = "ID of the security group for database instances (e.g., RDS)"
  value       = aws_security_group.database.id
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.name
}

output "kms_logs_alias_arn" {
  description = "The ARN of the KMS alias for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = aws_route_table.database[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role used by VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "sagemaker_api_endpoint_id" {
  description = "The ID of the SageMaker API VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_api.id
}

output "sagemaker_runtime_endpoint_id" {
  description = "The ID of the SageMaker Runtime VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_runtime.id
}

output "s3_gateway_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_api_endpoint_id" {
  description = "The ID of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "The ID of the ECR DKR VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "db_subnet_group_id" {
  description = "The ID of the DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}
