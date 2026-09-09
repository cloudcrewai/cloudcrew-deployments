output "kms_sagemaker_s3_key_id" {
  description = "KMS Key ID for SageMaker and S3 encryption"
  value       = aws_kms_key.main.key_id
}

output "kms_sagemaker_s3_key_arn" {
  description = "KMS Key ARN for SageMaker and S3 encryption"
  value       = aws_kms_key.main.arn
}

output "kms_sagemaker_s3_alias_name" {
  description = "KMS Alias Name for SageMaker and S3 encryption"
  value       = aws_kms_alias.main.name
}

output "kms_sagemaker_s3_alias_arn" {
  description = "KMS Alias ARN for SageMaker and S3 encryption"
  value       = aws_kms_alias.main.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "KMS Key ID for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "KMS Key ARN for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "KMS Alias Name for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.name
}

output "kms_cloudwatch_logs_alias_arn" {
  description = "KMS Alias ARN for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.arn
}

output "ecr_repository_name" {
  description = "ECR Repository Name for SageMaker images"
  value       = aws_ecr_repository.sagemaker_images.name
}

output "ecr_repository_arn" {
  description = "ECR Repository ARN for SageMaker images"
  value       = aws_ecr_repository.sagemaker_images.arn
}

output "ecr_repository_url" {
  description = "ECR Repository URL for SageMaker images"
  value       = aws_ecr_repository.sagemaker_images.repository_url
}

output "sagemaker_iam_role_name" {
  description = "IAM Role Name for SageMaker"
  value       = aws_iam_role.sagemaker.name
}

output "sagemaker_iam_role_arn" {
  description = "IAM Role ARN for SageMaker"
  value       = aws_iam_role.sagemaker.arn
}

output "sagemaker_model_package_group_name" {
  description = "SageMaker Model Package Group Name"
  value       = aws_sagemaker_model_package_group.main.model_package_group_name
}

output "sagemaker_model_package_group_arn" {
  description = "SageMaker Model Package Group ARN"
  value       = aws_sagemaker_model_package_group.main.arn
}

output "sagemaker_vpc_access_security_group_id" {
  description = "Security Group ID for SageMaker VPC access"
  value       = aws_security_group.sagemaker_vpc_access.id
}

output "sagemaker_vpc_access_security_group_arn" {
  description = "Security Group ARN for SageMaker VPC access"
  value       = aws_security_group.sagemaker_vpc_access.arn
}

output "sagemaker_model_name" {
  description = "SageMaker Model Name"
  value       = aws_sagemaker_model.main.name
}

output "sagemaker_model_arn" {
  description = "SageMaker Model ARN"
  value       = aws_sagemaker_model.main.arn
}

output "sagemaker_endpoint_configuration_name" {
  description = "SageMaker Endpoint Configuration Name"
  value       = aws_sagemaker_endpoint_configuration.main.name
}

output "sagemaker_endpoint_configuration_arn" {
  description = "SageMaker Endpoint Configuration ARN"
  value       = aws_sagemaker_endpoint_configuration.main.arn
}

output "sagemaker_endpoint_name" {
  description = "SageMaker Endpoint Name"
  value       = aws_sagemaker_endpoint.main.name
}

output "sagemaker_endpoint_arn" {
  description = "SageMaker Endpoint ARN"
  value       = aws_sagemaker_endpoint.main.arn
}

output "sagemaker_monitoring_schedule_name" {
  description = "SageMaker Monitoring Schedule Name"
  value       = aws_sagemaker_monitoring_schedule.main.name
}

output "sagemaker_monitoring_schedule_arn" {
  description = "SageMaker Monitoring Schedule ARN"
  value       = aws_sagemaker_monitoring_schedule.main.arn
}

output "sagemaker_log_group_name" {
  description = "CloudWatch Log Group Name for SageMaker"
  value       = aws_cloudwatch_log_group.sagemaker.name
}

output "sagemaker_log_group_arn" {
  description = "CloudWatch Log Group ARN for SageMaker"
  value       = aws_cloudwatch_log_group.sagemaker.arn
}

output "vpce_security_group_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = aws_security_group.vpce.id
}

output "vpce_security_group_arn" {
  description = "Security Group ARN for VPC Endpoints"
  value       = aws_security_group.vpce.arn
}

output "sagemaker_api_vpce_id" {
  description = "SageMaker API VPC Endpoint ID"
  value       = aws_vpc_endpoint.sagemaker_api.id
}

output "sagemaker_api_vpce_dns_names" {
  description = "SageMaker API VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.sagemaker_api.dns_entry[*].dns_name
}

output "sagemaker_runtime_vpce_id" {
  description = "SageMaker Runtime VPC Endpoint ID"
  value       = aws_vpc_endpoint.sagemaker_runtime.id
}

output "sagemaker_runtime_vpce_dns_names" {
  description = "SageMaker Runtime VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.sagemaker_runtime.dns_entry[*].dns_name
}

output "ecr_api_vpce_id" {
  description = "ECR API VPC Endpoint ID"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_vpce_dns_names" {
  description = "ECR API VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.ecr_api.dns_entry[*].dns_name
}

output "ecr_dkr_vpce_id" {
  description = "ECR Docker VPC Endpoint ID"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_dkr_vpce_dns_names" {
  description = "ECR Docker VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry[*].dns_name
}

output "kms_vpce_id" {
  description = "KMS VPC Endpoint ID"
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpce_dns_names" {
  description = "KMS VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.kms.dns_entry[*].dns_name
}

output "cloudwatch_logs_vpce_id" {
  description = "CloudWatch Logs VPC Endpoint ID"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_logs_vpce_dns_names" {
  description = "CloudWatch Logs VPC Endpoint DNS names"
  value       = aws_vpc_endpoint.cloudwatch_logs.dns_entry[*].dns_name
}

output "s3_gateway_vpce_id" {
  description = "S3 Gateway VPC Endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "s3_gateway_vpce_prefix_list_id" {
  description = "S3 Gateway VPC Endpoint Prefix List ID"
  value       = aws_vpc_endpoint.s3.prefix_list_id
}

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "GuardDuty Detector ARN"
  value       = aws_guardduty_detector.main.arn
}

output "securityhub_account_id" {
  description = "Security Hub Account ID"
  value       = aws_securityhub_account.main.id
}

output "config_iam_role_name" {
  description = "IAM Role Name for AWS Config"
  value       = aws_iam_role.config.name
}

output "config_iam_role_arn" {
  description = "IAM Role ARN for AWS Config"
  value       = aws_iam_role.config.arn
}

output "config_notifications_sns_topic_name" {
  description = "SNS Topic Name for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.name
}

output "config_notifications_sns_topic_arn" {
  description = "SNS Topic ARN for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.arn
}

output "alarms_sns_topic_name" {
  description = "SNS Topic Name for CloudWatch Alarms"
  value       = aws_sns_topic.alarms.name
}

output "alarms_sns_topic_arn" {
  description = "SNS Topic ARN for CloudWatch Alarms"
  value       = aws_sns_topic.alarms.arn
}

output "cloudtrail_iam_role_name" {
  description = "IAM Role Name for CloudTrail"
  value       = aws_iam_role.cloudtrail.name
}

output "cloudtrail_iam_role_arn" {
  description = "IAM Role ARN for CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch Log Group Name for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "CloudWatch Log Group ARN for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}
