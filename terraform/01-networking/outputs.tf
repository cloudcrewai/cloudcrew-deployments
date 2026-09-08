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
  description = "The ID of the security group for application instances"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the security group for database instances"
  value       = aws_security_group.db.id
}

output "db_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.db[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "db_route_table_ids" {
  description = "List of database route table IDs"
  value       = aws_route_table.db[*].id
}

output "nat_eip_public_ips" {
  description = "List of public IPs for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch logs"
  value       = aws_kms_alias.logs.name
}

output "kms_logs_alias_arn" {
  description = "The ARN of the KMS alias for CloudWatch logs"
  value       = aws_kms_alias.logs.arn
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

output "flow_logs_iam_role_name" {
  description = "The name of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.name
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "vpce_secrets_manager_security_group_id" {
  description = "The ID of the security group for the Secrets Manager VPC Endpoint"
  value       = aws_security_group.vpce_secrets_manager.id
}

output "vpce_kms_security_group_id" {
  description = "The ID of the security group for the KMS VPC Endpoint"
  value       = aws_security_group.vpce_kms.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}

output "secrets_manager_vpce_id" {
  description = "The ID of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "secrets_manager_vpce_dns_names" {
  description = "List of DNS names for the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.dns_entry[0].dns_name
}

output "kms_vpce_id" {
  description = "The ID of the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpce_dns_names" {
  description = "List of DNS names for the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.dns_entry[0].dns_name
}
