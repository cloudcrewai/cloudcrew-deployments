output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (app and data)"
  value       = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs (app and data)"
  value       = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
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

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs"
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

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "vpce_secretsmanager_id" {
  description = "The ID of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpce_ecr_docker_id" {
  description = "The ID of the ECR Docker VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_docker.id
}

output "vpce_kms_id" {
  description = "The ID of the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "vpce_dynamodb_id" {
  description = "The ID of the DynamoDB VPC Endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "vpce_s3_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "vpce_ecr_api_id" {
  description = "The ID of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "vpce_cloudwatch_logs_id" {
  description = "The ID of the CloudWatch Logs VPC Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "vpce_ssm_id" {
  description = "The ID of the SSM VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "vpce_security_group_id" {
  description = "The ID of the VPC Endpoint security group"
  value       = aws_security_group.vpce.id
}
