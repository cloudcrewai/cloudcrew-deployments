output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of all private subnets (app and data tiers)"
  value       = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
}

output "private_route_table_ids" {
  description = "List of IDs of all private route tables (app and data tiers)"
  value       = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.logs.name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log resource"
  value       = aws_flow_log.main.id
}

output "vpce_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpce.id
}

output "s3_gateway_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "ecr_api_endpoint_id" {
  description = "The ID of the ECR API Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_endpoint_dns_names" {
  description = "The DNS entries for the ECR API Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.dns_entry
}

output "cloudwatch_logs_endpoint_id" {
  description = "The ID of the CloudWatch Logs Interface VPC Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_logs_endpoint_dns_names" {
  description = "The DNS entries for the CloudWatch Logs Interface VPC Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.dns_entry
}

output "kms_endpoint_id" {
  description = "The ID of the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "kms_endpoint_dns_names" {
  description = "The DNS entries for the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms.dns_entry
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "dynamodb_gateway_endpoint_id" {
  description = "The ID of the DynamoDB Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.dynamodb_gateway.id
}

output "ecr_docker_endpoint_id" {
  description = "The ID of the ECR Docker Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_docker.id
}

output "ecr_docker_endpoint_dns_names" {
  description = "The DNS entries for the ECR Docker Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_docker.dns_entry
}

output "secrets_manager_endpoint_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "secrets_manager_endpoint_dns_names" {
  description = "The DNS entries for the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.dns_entry
}

output "ssm_endpoint_id" {
  description = "The ID of the SSM Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_endpoint_dns_names" {
  description = "The DNS entries for the SSM Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.dns_entry
}
