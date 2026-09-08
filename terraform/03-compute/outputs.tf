output "kms_secrets_manager_key_id" {
  description = "KMS Key ID for Secrets Manager"
  value       = aws_kms_key.secrets_manager.key_id
}

output "kms_secrets_manager_key_arn" {
  description = "KMS Key ARN for Secrets Manager"
  value       = aws_kms_key.secrets_manager.arn
}

output "kms_secrets_manager_alias_name" {
  description = "KMS Alias Name for Secrets Manager"
  value       = aws_kms_alias.secrets_manager.name
}

output "kms_ecr_key_id" {
  description = "KMS Key ID for ECR"
  value       = aws_kms_key.ecr.key_id
}

output "kms_ecr_key_arn" {
  description = "KMS Key ARN for ECR"
  value       = aws_kms_key.ecr.arn
}

output "kms_ecr_alias_name" {
  description = "KMS Alias Name for ECR"
  value       = aws_kms_alias.ecr.name
}

output "kms_sns_key_id" {
  description = "KMS Key ID for SNS"
  value       = aws_kms_key.sns.key_id
}

output "kms_sns_key_arn" {
  description = "KMS Key ARN for SNS"
  value       = aws_kms_key.sns.arn
}

output "kms_sns_alias_name" {
  description = "KMS Alias Name for SNS"
  value       = aws_kms_alias.sns.name
}

output "kms_alb_logs_key_id" {
  description = "KMS Key ID for ALB Access Logs"
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "KMS Key ARN for ALB Access Logs"
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_alias_name" {
  description = "KMS Alias Name for ALB Access Logs"
  value       = aws_kms_alias.alb_logs.name
}

output "kms_waf_logs_key_id" {
  description = "KMS Key ID for WAF Logs"
  value       = aws_kms_key.waf_logs.key_id
}

output "kms_waf_logs_key_arn" {
  description = "KMS Key ARN for WAF Logs"
  value       = aws_kms_key.waf_logs.arn
}

output "kms_waf_logs_alias_name" {
  description = "KMS Alias Name for WAF Logs"
  value       = aws_kms_alias.waf_logs.name
}

output "kms_config_logs_key_id" {
  description = "KMS Key ID for AWS Config Logs"
  value       = aws_kms_key.config_logs.key_id
}

output "kms_config_logs_key_arn" {
  description = "KMS Key ARN for AWS Config Logs"
  value       = aws_kms_key.config_logs.arn
}

output "kms_config_logs_alias_name" {
  description = "KMS Alias Name for AWS Config Logs"
  value       = aws_kms_alias.config_logs.name
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the Security Group for VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "ID of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_vpc_endpoint_dns_name" {
  description = "DNS Name of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.dns_entry[0].dns_name
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "ID of the ECR DKR VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_dkr_vpc_endpoint_dns_name" {
  description = "DNS Name of the ECR DKR VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry[0].dns_name
}

output "logs_vpc_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC Endpoint"
  value       = aws_vpc_endpoint.logs.id
}

output "logs_vpc_endpoint_dns_name" {
  description = "DNS Name of the CloudWatch Logs VPC Endpoint"
  value       = aws_vpc_endpoint.logs.dns_entry[0].dns_name
}

output "secretsmanager_vpc_endpoint_id" {
  description = "ID of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "secretsmanager_vpc_endpoint_dns_name" {
  description = "DNS Name of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.dns_entry[0].dns_name
}

output "kms_vpc_endpoint_id" {
  description = "ID of the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpc_endpoint_dns_name" {
  description = "DNS Name of the KMS VPC Endpoint"
  value       = aws_vpc_endpoint.kms.dns_entry[0].dns_name
}

output "ssm_vpc_endpoint_id" {
  description = "ID of the SSM VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_vpc_endpoint_dns_name" {
  description = "DNS Name of the SSM VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.dns_entry[0].dns_name
}

output "ssmmessages_vpc_endpoint_id" {
  description = "ID of the SSM Messages VPC Endpoint"
  value       = aws_vpc_endpoint.ssmmessages.id
}

output "ssmmessages_vpc_endpoint_dns_name" {
  description = "DNS Name of the SSM Messages VPC Endpoint"
  value       = aws_vpc_endpoint.ssmmessages.dns_entry[0].dns_name
}

output "ec2messages_vpc_endpoint_id" {
  description = "ID of the EC2 Messages VPC Endpoint"
  value       = aws_vpc_endpoint.ec2messages.id
}

output "ec2messages_vpc_endpoint_dns_name" {
  description = "DNS Name of the EC2 Messages VPC Endpoint"
  value       = aws_vpc_endpoint.ec2messages.dns_entry[0].dns_name
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "secrets_manager_db_credentials_arn" {
  description = "ARN of the DB credentials secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secrets_manager_db_credentials_name" {
  description = "Name of the DB credentials secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.bucket
}

output "alb_logs_bucket_arn" {
  description = "ARN of the S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group for ECS service"
  value       = aws_lb_target_group.ecs_service.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB Target Group for ECS service"
  value       = aws_lb_target_group.ecs_service.name
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_logs_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "waf_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution IAM Role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task IAM Role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_service_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service.name
}

output "ecs_service_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service"
  value       = aws_ecs_service.app.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty Detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_findings_sns_topic_arn" {
  description = "ARN of the SNS Topic for GuardDuty findings"
  value       = aws_sns_topic.guardduty_findings.arn
}

output "guardduty_findings_sns_topic_name" {
  description = "Name of the SNS Topic for GuardDuty findings"
  value       = aws_sns_topic.guardduty_findings.name
}

output "config_logs_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_logs_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "config_notifications_sns_topic_arn" {
  description = "ARN of the SNS Topic for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.arn
}

output "config_notifications_sns_topic_name" {
  description = "Name of the SNS Topic for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.name
}

output "config_recorder_name" {
  description = "Name of the AWS Config Configuration Recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_delivery_channel_name" {
  description = "Name of the AWS Config Delivery Channel"
  value       = aws_config_delivery_channel.main.name
}

output "alarms_sns_topic_arn" {
  description = "ARN of the SNS Topic for CloudWatch Alarms"
  value       = aws_sns_topic.alarms.arn
}

output "alarms_sns_topic_name" {
  description = "Name of the SNS Topic for CloudWatch Alarms"
  value       = aws_sns_topic.alarms.name
}
