output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "app_security_group_id" {
  description = "The ID of the security group for application tasks"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS database"
  value       = aws_security_group.db.id
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.logs.name
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "database_route_table_ids" {
  description = "List of database route table IDs"
  value       = aws_route_table.database[*].id
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache Redis"
  value       = aws_security_group.elasticache.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
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
  description = "The ARN of the IAM Role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager VPC Interface Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "The ID of the ECR API VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "The ID of the ECR DKR VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs VPC Interface Endpoint"
  value       = aws_vpc_endpoint.logs.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS VPC Interface Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "ssm_vpc_endpoint_id" {
  description = "The ID of the SSM VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "The ID of the SSM Messages VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "The ID of the EC2 Messages VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ec2_messages.id
}
