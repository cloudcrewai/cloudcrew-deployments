output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private application and data subnets"
  value       = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private application and data route tables"
  value       = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.name
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
  description = "The ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "secrets_manager_vpce_id" {
  description = "The ID of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "dynamodb_vpce_id" {
  description = "The ID of the DynamoDB VPC Endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "ecr_docker_vpce_id" {
  description = "The ID of the ECR Docker VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_docker.id
}

output "kms_vpce_id" {
  description = "The ID of the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "s3_vpce_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_api_vpce_id" {
  description = "The ID of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "cloudwatch_logs_vpce_id" {
  description = "The ID of the CloudWatch Logs VPC Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "ssm_vpce_id" {
  description = "The ID of the SSM VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "vpce_interface_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpce_interface.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_eip_ids" {
  description = "List of IDs of the Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].id
}
