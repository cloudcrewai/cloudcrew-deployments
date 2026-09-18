output "kms_elasticache_key_id" {
  description = "KMS Key ID for ElastiCache encryption"
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "KMS Key ARN for ElastiCache encryption"
  value       = aws_kms_key.elasticache.arn
}

output "kms_elasticache_alias_name" {
  description = "KMS Alias Name for ElastiCache encryption"
  value       = aws_kms_alias.elasticache.name
}

output "kms_logs_key_id" {
  description = "KMS Key ID for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "KMS Key ARN for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "KMS Alias Name for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.name
}

output "kms_alb_logs_key_id" {
  description = "KMS Key ID for ALB Logs encryption"
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "KMS Key ARN for ALB Logs encryption"
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_alias_name" {
  description = "KMS Alias Name for ALB Logs encryption"
  value       = aws_kms_alias.alb_logs.name
}

output "kms_rds_key_id" {
  description = "KMS Key ID for RDS encryption"
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "KMS Key ARN for RDS encryption"
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_name" {
  description = "KMS Alias Name for RDS encryption"
  value       = aws_kms_alias.rds.name
}

output "kms_backup_key_id" {
  description = "KMS Key ID for AWS Backup encryption"
  value       = aws_kms_key.backup.key_id
}

output "kms_backup_key_arn" {
  description = "KMS Key ARN for AWS Backup encryption"
  value       = aws_kms_key.backup.arn
}

output "kms_backup_alias_name" {
  description = "KMS Alias Name for AWS Backup encryption"
  value       = aws_kms_alias.backup.name
}

output "ecs_task_iam_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_iam_role_name" {
  description = "Name of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task.name
}

output "ecs_execution_iam_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_execution.arn
}

output "ecs_execution_iam_role_name" {
  description = "Name of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_execution.name
}

output "config_iam_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  value       = aws_iam_role.config.arn
}

output "config_iam_role_name" {
  description = "Name of the IAM role for AWS Config"
  value       = aws_iam_role.config.name
}

output "eventbridge_guardduty_sns_iam_role_arn" {
  description = "ARN of the IAM role for EventBridge to publish GuardDuty findings to SNS"
  value       = aws_iam_role.eventbridge_guardduty_sns.arn
}

output "eventbridge_guardduty_sns_iam_role_name" {
  description = "Name of the IAM role for EventBridge to publish GuardDuty findings to SNS"
  value       = aws_iam_role.eventbridge_guardduty_sns.name
}

output "cloudtrail_iam_role_arn" {
  description = "ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_iam_role_name" {
  description = "Name of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail.name
}

output "securityhub_iam_role_arn" {
  description = "ARN of the IAM role for Security Hub"
  value       = aws_iam_role.securityhub.arn
}

output "securityhub_iam_role_name" {
  description = "Name of the IAM role for Security Hub"
  value       = aws_iam_role.securityhub.name
}

output "lambda_redis_rotation_iam_role_arn" {
  description = "ARN of the IAM role for the Redis password rotation Lambda"
  value       = aws_iam_role.lambda_redis_rotation.arn
}

output "lambda_redis_rotation_iam_role_name" {
  description = "Name of the IAM role for the Redis password rotation Lambda"
  value       = aws_iam_role.lambda_redis_rotation.name
}

output "backup_iam_role_arn" {
  description = "ARN of the IAM role for AWS Backup"
  value       = aws_iam_role.backup.arn
}

output "backup_iam_role_name" {
  description = "Name of the IAM role for AWS Backup"
  value       = aws_iam_role.backup.name
}

output "config_logs_s3_bucket_id" {
  description = "ID of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.id
}

output "config_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "config_logs_s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket_regional_domain_name
}

output "secrets_manager_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "secrets_manager_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secrets_manager.dns_entry[0].dns_name
}

output "ecr_api_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for ECR API"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for ECR API"
  value       = aws_vpc_endpoint.ecr_api.dns_entry[0].dns_name
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for ECR DKR"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_dkr_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for ECR DKR"
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry[0].dns_name
}

output "cloudwatch_logs_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for CloudWatch Logs"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_logs_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for CloudWatch Logs"
  value       = aws_vpc_endpoint.cloudwatch_logs.dns_entry[0].dns_name
}

output "kms_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for KMS"
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for KMS"
  value       = aws_vpc_endpoint.kms.dns_entry[0].dns_name
}

output "ssm_vpc_endpoint_id" {
  description = "ID of the VPC endpoint for SSM"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_vpc_endpoint_dns_names" {
  description = "DNS names of the VPC endpoint for SSM"
  value       = aws_vpc_endpoint.ssm.dns_entry[0].dns_name
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "cloudtrail_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "waf_cloudfront_logs_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF CloudFront logs"
  value       = aws_cloudwatch_log_group.waf_cloudfront_logs.name
}

output "waf_cloudfront_logs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF CloudFront logs"
  value       = aws_cloudwatch_log_group.waf_cloudfront_logs.arn
}

output "waf_regional_logs_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF Regional logs"
  value       = aws_cloudwatch_log_group.waf_regional_logs.name
}

output "waf_regional_logs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF Regional logs"
  value       = aws_cloudwatch_log_group.waf_regional_logs.arn
}

output "ecs_app_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_app_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "config_log_group_name" {
  description = "Name of the CloudWatch Log Group for AWS Config logs"
  value       = aws_cloudwatch_log_group.config.name
}

output "config_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for AWS Config logs"
  value       = aws_cloudwatch_log_group.config.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.name
}

output "sns_guardduty_findings_topic_arn" {
  description = "ARN of the SNS topic for GuardDuty findings"
  value       = aws_sns_topic.guardduty_findings.arn
}

output "sns_guardduty_findings_topic_name" {
  description = "Name of the SNS topic for GuardDuty findings"
  value       = aws_sns_topic.guardduty_findings.name
}

output "sns_config_notifications_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.arn
}

output "sns_config_notifications_topic_name" {
  description = "Name of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = aws_acm_certificate.main.domain_name
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
  description = "ARN of the ALB target group for the application"
  value       = aws_lb_target_group.app.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB target group for the application"
  value       = aws_lb_target_group.app.name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_oac_id" {
  description = "ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.main.id
}

output "cloudfront_oac_arn" {
  description = "ARN of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.main.arn
}

output "waf_cloudfront_web_acl_arn" {
  description = "ARN of the CloudFront WAF Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "waf_cloudfront_web_acl_id" {
  description = "ID of the CloudFront WAF Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.id
}

output "waf_cloudfront_web_acl_name" {
  description = "Name of the CloudFront WAF Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.name
}

output "waf_regional_web_acl_arn" {
  description = "ARN of the Regional WAF Web ACL"
  value       = aws_wafv2_web_acl.regional.arn
}

output "waf_regional_web_acl_id" {
  description = "ID of the Regional WAF Web ACL"
  value       = aws_wafv2_web_acl.regional.id
}

output "waf_regional_web_acl_name" {
  description = "Name of the Regional WAF Web ACL"
  value       = aws_wafv2_web_acl.regional.name
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition for the application"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "Family of the ECS task definition for the application"
  value       = aws_ecs_task_definition.app.family
}

output "ecs_service_id" {
  description = "ID of the ECS service for the application"
  value       = aws_ecs_service.app.id
}

output "ecs_service_arn" {
  description = "ARN of the ECS service for the application"
  value       = aws_ecs_service.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service for the application"
  value       = aws_ecs_service.app.name
}

output "route53_hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "route53_hosted_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = aws_route53_zone.main.name
}

output "app_alias_record_fqdn" {
  description = "Fully qualified domain name of the application alias record"
  value       = aws_route53_record.app_alias.fqdn
}

output "redis_auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret for Redis auth token"
  value       = aws_secretsmanager_secret.redis_auth_token.arn
}

output "redis_auth_token_secret_name" {
  description = "Name of the Secrets Manager secret for Redis auth token"
  value       = aws_secretsmanager_secret.redis_auth_token.name
}

output "lambda_redis_rotation_function_arn" {
  description = "ARN of the Lambda function for Redis password rotation"
  value       = aws_lambda_function.redis_rotation.arn
}

output "lambda_redis_rotation_function_name" {
  description = "Name of the Lambda function for Redis password rotation"
  value       = aws_lambda_function.redis_rotation.function_name
}

output "eventbridge_guardduty_findings_rule_arn" {
  description = "ARN of the EventBridge rule for GuardDuty findings"
  value       = aws_cloudwatch_event_rule.guardduty_findings.arn
}

output "eventbridge_guardduty_findings_rule_name" {
  description = "Name of the EventBridge rule for GuardDuty findings"
  value       = aws_cloudwatch_event_rule.guardduty_findings.name
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.main.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.main.name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch operational dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cloudwatch_dashboard_arn" {
  description = "ARN of the CloudWatch operational dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "backup_vault_name" {
  description = "Name of the AWS Backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "ID of the AWS Backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "ARN of the AWS Backup plan"
  value       = aws_backup_plan.main.arn
}

output "backup_plan_name" {
  description = "Name of the AWS Backup plan"
  value       = aws_backup_plan.main.name
}
