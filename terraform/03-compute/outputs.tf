output "kms_s3_assets_key_id" {
  description = "KMS Key ID for S3 application assets"
  value       = aws_kms_key.s3_assets.key_id
}

output "kms_s3_assets_key_arn" {
  description = "KMS Key ARN for S3 application assets"
  value       = aws_kms_key.s3_assets.arn
}

output "kms_s3_assets_alias_name" {
  description = "KMS Alias Name for S3 application assets"
  value       = aws_kms_alias.s3_assets.name
}

output "kms_alb_logs_key_id" {
  description = "KMS Key ID for ALB access logs"
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "KMS Key ARN for ALB access logs"
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_alias_name" {
  description = "KMS Alias Name for ALB access logs"
  value       = aws_kms_alias.alb_logs.name
}

output "kms_cloudwatch_logs_key_id" {
  description = "KMS Key ID for CloudWatch Logs encryption"
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "KMS Key ARN for CloudWatch Logs encryption"
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "KMS Alias Name for CloudWatch Logs encryption"
  value       = aws_kms_alias.cloudwatch_logs.name
}

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

output "secrets_manager_app_secrets_arn" {
  description = "ARN of the application secrets in Secrets Manager"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secrets_manager_app_secrets_name" {
  description = "Name of the application secrets in Secrets Manager"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "ecs_task_iam_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_execution_iam_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "alb_logs_iam_role_arn" {
  description = "ARN of the IAM role for ALB logs"
  value       = aws_iam_role.alb_logs.arn
}

output "cloudwatch_alarms_sns_iam_role_arn" {
  description = "ARN of the IAM role for CloudWatch alarms to publish to SNS"
  value       = aws_iam_role.cloudwatch_alarms_sns.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Canonical Hosted Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group for the application"
  value       = aws_lb_target_group.app.arn
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
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service.name
}

output "ecs_service_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition for the application"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "Family of the ECS task definition for the application"
  value       = aws_ecs_task_definition.app.family
}

output "ecs_service_name" {
  description = "Name of the ECS service for the application"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service for the application"
  value       = aws_ecs_service.app.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.name
}
