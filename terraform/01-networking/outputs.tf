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

output "app_security_group_id" {
  description = "The ID of the application security group."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.db.id
}

output "vpc_arn" {
  description = "The ARN of the main VPC."
  value       = aws_vpc.main.arn
}

output "vpc_default_security_group_id" {
  description = "The ID of the default security group for the VPC."
  value       = aws_vpc.main.default_security_group_id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "public_eip_allocation_ids" {
  description = "List of allocation IDs for the public EIPs attached to NAT Gateways."
  value       = aws_eip.nat[*].id
}

output "public_eip_public_ips" {
  description = "List of public IPs for the EIPs attached to NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for logs."
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for logs."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS key alias for logs."
  value       = aws_kms_alias.logs.name
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3."
  value       = aws_kms_key.s3.id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_name" {
  description = "The name of the KMS key alias for S3."
  value       = aws_kms_alias.s3.name
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "flow_logs_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudtrail_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector."
  value       = aws_guardduty_detector.main.arn
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "config_notifications_sns_topic_name" {
  description = "The name of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.name
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for general alarms."
  value       = aws_sns_topic.alarms.arn
}

output "alarms_sns_topic_name" {
  description = "The name of the SNS topic for general alarms."
  value       = aws_sns_topic.alarms.name
}

output "secretsmanager_vpce_dns_names" {
  description = "DNS entries for the Secrets Manager VPC endpoint."
  value       = aws_vpc_endpoint.secretsmanager.dns_entry
}

output "kms_vpce_dns_names" {
  description = "DNS entries for the KMS VPC endpoint."
  value       = aws_vpc_endpoint.kms.dns_entry
}

output "ecr_api_vpce_dns_names" {
  description = "DNS entries for the ECR API VPC endpoint."
  value       = aws_vpc_endpoint.ecr_api.dns_entry
}

output "ecr_dkr_vpce_dns_names" {
  description = "DNS entries for the ECR DKR VPC endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry
}

output "logs_vpce_dns_names" {
  description = "DNS entries for the CloudWatch Logs VPC endpoint."
  value       = aws_vpc_endpoint.logs.dns_entry
}

output "ssm_vpce_dns_names" {
  description = "DNS entries for the SSM VPC endpoint."
  value       = aws_vpc_endpoint.ssm.dns_entry
}

output "ssm_messages_vpce_dns_names" {
  description = "DNS entries for the SSM Messages VPC endpoint."
  value       = aws_vpc_endpoint.ssm_messages.dns_entry
}

output "ec2_vpce_dns_names" {
  description = "DNS entries for the EC2 VPC endpoint."
  value       = aws_vpc_endpoint.ec2.dns_entry
}

output "ec2_messages_vpce_dns_names" {
  description = "DNS entries for the EC2 Messages VPC endpoint."
  value       = aws_vpc_endpoint.ec2_messages.dns_entry
}
