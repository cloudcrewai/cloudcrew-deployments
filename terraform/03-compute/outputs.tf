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

output "kms_elasticache_alias_arn" {
  description = "KMS Alias ARN for ElastiCache encryption"
  value       = aws_kms_alias.elasticache.arn
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

output "kms_logs_alias_arn" {
  description = "KMS Alias ARN for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_backup_dr_key_id" {
  description = "KMS Key ID for DR Backup encryption"
  value       = aws_kms_key.backup_dr.key_id
}

output "kms_backup_dr_key_arn" {
  description = "KMS Key ARN for DR Backup encryption"
  value       = aws_kms_key.backup_dr.arn
}

output "backup_dr_vault_name" {
  description = "Name of the DR Backup Vault"
  value       = aws_backup_vault.dr.name
}

output "backup_dr_vault_arn" {
  description = "ARN of the DR Backup Vault"
  value       = aws_backup_vault.dr.arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM Certificate"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM Certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "waf_cloudfront_web_acl_arn" {
  description = "ARN of the CloudFront WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "waf_cloudfront_web_acl_id" {
  description = "ID of the CloudFront WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.cloudfront.id
}

output "waf_regional_web_acl_arn" {
  description = "ARN of the Regional WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.regional.arn
}

output "waf_regional_web_acl_id" {
  description = "ID of the Regional WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.regional.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Route53 Hosted Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group for the application"
  value       = aws_lb_target_group.app.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB Target Group for the application"
  value       = aws_lb_target_group.app.name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "Hosted Zone ID of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "app_dns_fqdn" {
  description = "Fully Qualified Domain Name (FQDN) for the application"
  value       = aws_route53_record.app_dns.fqdn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR Repository for the application"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL of the ECR Repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR Repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM Role for ECS Task Execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the IAM Role for ECS Tasks"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_app_service_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS App Service"
  value       = aws_cloudwatch_log_group.ecs_app_service.name
}

output "ecs_app_service_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS App Service"
  value       = aws_cloudwatch_log_group.ecs_app_service.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the application"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service for the application"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service for the application"
  value       = aws_ecs_service.app.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS Topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS Topic for alarms"
  value       = aws_sns_topic.alarms.name
}

output "cloudtrail_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty Detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty Detector"
  value       = aws_guardduty_detector.main.arn
}

output "secretsmanager_redis_auth_token_arn" {
  description = "ARN of the Secrets Manager secret for Redis AUTH token"
  value       = aws_secretsmanager_secret.redis_auth_token.arn
}

output "secretsmanager_redis_auth_token_name" {
  description = "Name of the Secrets Manager secret for Redis AUTH token"
  value       = aws_secretsmanager_secret.redis_auth_token.name
}

output "cloudwatch_operational_dashboard_name" {
  description = "Name of the CloudWatch Operational Dashboard"
  value       = aws_cloudwatch_dashboard.operational.dashboard_name
}

output "backup_plan_id" {
  description = "ID of the AWS Backup Plan"
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "ARN of the AWS Backup Plan"
  value       = aws_backup_plan.main.arn
}

output "backup_plan_name" {
  description = "Name of the AWS Backup Plan"
  value       = aws_backup_plan.main.name
}

output "backup_service_role_arn" {
  description = "ARN of the IAM Role for AWS Backup service"
  value       = aws_iam_role.backup_service_role.arn
}
