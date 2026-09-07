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
  description = "List of NAT Gateway IDs (if enabled)"
  value       = aws_nat_gateway.main[*].id
}

output "app_security_group_id" {
  description = "The ID of the security group for application ECS tasks"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS database"
  value       = aws_security_group.db.id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "database_route_table_ids" {
  description = "List of database route table IDs"
  value       = aws_route_table.database[*].id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "general_kms_key_id" {
  description = "The ID of the general purpose KMS key"
  value       = aws_kms_key.main.id
}

output "general_kms_key_arn" {
  description = "The ARN of the general purpose KMS key"
  value       = aws_kms_key.main.arn
}

output "logs_kms_key_id" {
  description = "The ID of the KMS key for logs encryption"
  value       = aws_kms_key.logs.id
}

output "logs_kms_key_arn" {
  description = "The ARN of the KMS key for logs encryption"
  value       = aws_kms_key.logs.arn
}

output "logs_kms_alias_name" {
  description = "The name of the KMS alias for logs encryption"
  value       = aws_kms_alias.logs.name
}

output "s3_kms_key_id" {
  description = "The ID of the KMS key for S3 encryption"
  value       = aws_kms_key.s3.id
}

output "s3_kms_key_arn" {
  description = "The ARN of the KMS key for S3 encryption"
  value       = aws_kms_key.s3.arn
}

output "backup_kms_key_id" {
  description = "The ID of the KMS key for AWS Backup"
  value       = aws_kms_key.backup.id
}

output "backup_kms_key_arn" {
  description = "The ARN of the KMS key for AWS Backup"
  value       = aws_kms_key.backup.arn
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

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM Role for CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_notifications_topic_arn" {
  description = "The ARN of the SNS Topic for CloudTrail notifications"
  value       = aws_sns_topic.cloudtrail_notifications.arn
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail trail"
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "security_alarms_topic_arn" {
  description = "The ARN of the SNS Topic for security alarms"
  value       = aws_sns_topic.security_alarms.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The AWS account ID where Security Hub is enabled"
  value       = aws_securityhub_account.main.id
}

output "config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "config_notifications_topic_arn" {
  description = "The ARN of the SNS Topic for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM Role for AWS Config"
  value       = aws_iam_role.config.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_iam_role_arn" {
  description = "The ARN of the IAM Role for AWS Backup"
  value       = aws_iam_role.backup.arn
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "The ID of the ECR API Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "The ID of the ECR DKR Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "ssm_vpc_endpoint_id" {
  description = "The ID of the SSM Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "The ID of the SSM Messages Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_vpc_endpoint_id" {
  description = "The ID of the EC2 Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "The ID of the EC2 Messages Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ec2_messages.id
}

output "cloudwatch_logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs Interface VPC Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}
