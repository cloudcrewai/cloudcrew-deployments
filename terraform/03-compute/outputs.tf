output "kms_app_key_id" {
  description = "The ID of the KMS key for application secrets."
  value       = aws_kms_key.app.key_id
}

output "kms_app_key_arn" {
  description = "The ARN of the KMS key for application secrets."
  value       = aws_kms_key.app.arn
}

output "kms_app_alias_name" {
  description = "The name of the KMS alias for application secrets."
  value       = aws_kms_alias.app.name
}

output "kms_app_alias_arn" {
  description = "The ARN of the KMS alias for application secrets."
  value       = aws_kms_alias.app.arn
}

output "kms_alb_logs_key_id" {
  description = "The ID of the KMS key for ALB access logs."
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "The ARN of the KMS key for ALB access logs."
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_alias_name" {
  description = "The name of the KMS alias for ALB access logs."
  value       = aws_kms_alias.alb_logs.name
}

output "kms_alb_logs_alias_arn" {
  description = "The ARN of the KMS alias for ALB access logs."
  value       = aws_kms_alias.alb_logs.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch logs."
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch logs."
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch logs."
  value       = aws_kms_alias.cloudwatch_logs.name
}

output "kms_cloudwatch_logs_alias_arn" {
  description = "The ARN of the KMS alias for CloudWatch logs."
  value       = aws_kms_alias.cloudwatch_logs.arn
}

output "secretsmanager_db_credentials_arn" {
  description = "The ARN of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secretsmanager_db_credentials_name" {
  description = "The name of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "The name of the ECR repository for the application image."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository for the application image."
  value       = aws_ecr_repository.app.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "The ARN of the ALB target group for the application."
  value       = aws_lb_target_group.app.arn
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener for the ALB."
  value       = aws_lb_listener.https.arn
}

output "alb_http_redirect_listener_arn" {
  description = "The ARN of the HTTP redirect listener for the ALB."
  value       = aws_lb_listener.http_redirect.arn
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL."
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL."
  value       = aws_wafv2_web_acl.main.id
}

output "waf_logs_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "waf_logs_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "The name of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "The name of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.name
}

output "ecs_task_policy_arn" {
  description = "The ARN of the ECS task IAM policy."
  value       = aws_iam_policy.ecs_task_policy.arn
}

output "ecs_task_policy_name" {
  description = "The name of the ECS task IAM policy."
  value       = aws_iam_policy.ecs_task_policy.name
}

output "ecs_app_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_app_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition for the application."
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "The family of the ECS task definition for the application."
  value       = aws_ecs_task_definition.app.family
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "ecs_service_id" {
  description = "The ID of the ECS service."
  value       = aws_ecs_service.app.id
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service."
  value       = aws_ecs_service.app.arn
}

output "appautoscaling_ecs_app_resource_id" {
  description = "The resource ID for ECS service auto-scaling target."
  value       = aws_appautoscaling_target.ecs_app.resource_id
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.name
}
