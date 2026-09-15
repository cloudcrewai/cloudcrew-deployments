output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_name" {
  description = "The name of the KMS alias for RDS encryption."
  value       = aws_kms_alias.rds.name
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_elasticache_alias_name" {
  description = "The name of the KMS alias for ElastiCache encryption."
  value       = aws_kms_alias.elasticache.name
}

output "kms_s3_alb_logs_key_id" {
  description = "The ID of the KMS key for S3 ALB logs encryption."
  value       = aws_kms_key.s3_alb_logs.key_id
}

output "kms_s3_alb_logs_key_arn" {
  description = "The ARN of the KMS key for S3 ALB logs encryption."
  value       = aws_kms_key.s3_alb_logs.arn
}

output "kms_s3_alb_logs_alias_name" {
  description = "The name of the KMS alias for S3 ALB logs encryption."
  value       = aws_kms_alias.s3_alb_logs.name
}

output "kms_secrets_manager_key_id" {
  description = "The ID of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets_manager.key_id
}

output "kms_secrets_manager_key_arn" {
  description = "The ARN of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets_manager.arn
}

output "kms_secrets_manager_alias_name" {
  description = "The name of the KMS alias for Secrets Manager encryption."
  value       = aws_kms_alias.secrets_manager.name
}

output "kms_cloudwatch_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs encryption."
  value       = aws_kms_alias.logs.name
}

output "alb_logs_s3_bucket_id" {
  description = "The ID of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "alb_logs_s3_bucket_name" {
  description = "The name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "route53_hosted_zone_id" {
  description = "The ID of the Route53 hosted zone."
  value       = aws_route53_zone.main.zone_id
}

output "route53_hosted_zone_name" {
  description = "The name of the Route53 hosted zone."
  value       = aws_route53_zone.main.name
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_name" {
  description = "The domain name of the ACM certificate."
  value       = aws_acm_certificate.main.domain_name
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "The ID of the WAFv2 Web ACL."
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

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The Route53 Hosted Zone ID of the Application Load Balancer."
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "The ARN of the ECS application target group."
  value       = aws_lb_target_group.ecs_app.arn
}

output "alb_target_group_name" {
  description = "The name of the ECS application target group."
  value       = aws_lb_target_group.ecs_app.name
}

output "alb_http_listener_arn" {
  description = "The ARN of the HTTP listener for the ALB."
  value       = aws_lb_listener.http.arn
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener for the ALB."
  value       = aws_lb_listener.https.arn
}

output "ecr_repository_name" {
  description = "The name of the ECR repository for the application."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for the application."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository for the application."
  value       = aws_ecr_repository.app.arn
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "The family of the ECS task definition."
  value       = aws_ecs_task_definition.app.family
}

output "ecs_app_log_group_name" {
  description = "The name of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_app_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "ecs_service_id" {
  description = "The ID of the ECS service."
  value       = aws_ecs_service.app.id
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service."
  value       = aws_ecs_service.app.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "secrets_manager_db_credentials_arn" {
  description = "The ARN of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secrets_manager_db_credentials_name" {
  description = "The name of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "secrets_rotation_lambda_function_arn" {
  description = "The ARN of the Lambda function for secrets rotation."
  value       = aws_lambda_function.secrets_rotation.arn
}

output "secrets_rotation_lambda_function_name" {
  description = "The name of the Lambda function for secrets rotation."
  value       = aws_lambda_function.secrets_rotation.function_name
}

output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "ecs_cpu_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for ECS CPU utilization."
  value       = aws_cloudwatch_metric_alarm.ecs_cpu.arn
}

output "ecs_memory_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for ECS memory utilization."
  value       = aws_cloudwatch_metric_alarm.ecs_memory.arn
}
