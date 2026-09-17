output "kms_elasticache_key_id" {
  description = "KMS Key ID for ElastiCache encryption"
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "KMS Key ARN for ElastiCache encryption"
  value       = aws_kms_key.elasticache.arn
}

output "kms_alb_logs_key_id" {
  description = "KMS Key ID for ALB access logs encryption"
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "KMS Key ARN for ALB access logs encryption"
  value       = aws_kms_key.alb_logs.arn
}

output "kms_cloudtrail_logs_key_id" {
  description = "KMS Key ID for CloudTrail logs encryption"
  value       = aws_kms_key.cloudtrail_logs.key_id
}

output "kms_cloudtrail_logs_key_arn" {
  description = "KMS Key ARN for CloudTrail logs encryption"
  value       = aws_kms_key.cloudtrail_logs.arn
}

output "kms_ebs_key_id" {
  description = "KMS Key ID for EBS encryption"
  value       = aws_kms_key.ebs.key_id
}

output "kms_ebs_key_arn" {
  description = "KMS Key ARN for EBS encryption"
  value       = aws_kms_key.ebs.arn
}

output "kms_rds_key_id" {
  description = "KMS Key ID for RDS encryption"
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "KMS Key ARN for RDS encryption"
  value       = aws_kms_key.rds.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "KMS Key ID for general CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "KMS Key ARN for general CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_flow_logs_key_id" {
  description = "KMS Key ID for VPC Flow Logs encryption"
  value       = aws_kms_key.flow_logs.key_id
}

output "kms_flow_logs_key_arn" {
  description = "KMS Key ARN for VPC Flow Logs encryption"
  value       = aws_kms_key.flow_logs.arn
}

output "kms_sns_key_id" {
  description = "KMS Key ID for SNS encryption"
  value       = aws_kms_key.sns.key_id
}

output "kms_sns_key_arn" {
  description = "KMS Key ARN for SNS encryption"
  value       = aws_kms_key.sns.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "waf_cloudfront_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL for CloudFront"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "waf_regional_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL for regional ALB"
  value       = aws_wafv2_web_acl.regional.arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
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

output "ecs_service_arn" {
  description = "ARN of the ECS service for the application"
  value       = aws_ecs_service.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service for the application"
  value       = aws_ecs_service.app.name
}

output "ec2_ssm_debug_instance_id" {
  description = "ID of the EC2 instance for SSM debugging"
  value       = aws_instance.ssm_debug.id
}

output "secrets_manager_redis_auth_arn" {
  description = "ARN of the Secrets Manager secret for Redis authentication"
  value       = aws_secretsmanager_secret.redis_auth.arn
}

output "secrets_manager_redis_auth_name" {
  description = "Name of the Secrets Manager secret for Redis authentication"
  value       = aws_secretsmanager_secret.redis_auth.name
}

output "lambda_rotation_function_arn" {
  description = "ARN of the Lambda function for secret rotation"
  value       = aws_lambda_function.rotation.arn
}

output "sns_guardduty_alerts_topic_arn" {
  description = "ARN of the SNS topic for GuardDuty alerts"
  value       = aws_sns_topic.guardduty_alerts.arn
}

output "sns_guardduty_alerts_topic_name" {
  description = "Name of the SNS topic for GuardDuty alerts"
  value       = aws_sns_topic.guardduty_alerts.name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cost_anomaly_monitor_arn" {
  description = "ARN of the Cost Anomaly Monitor"
  value       = aws_ce_anomaly_monitor.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.main.arn
}

output "config_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "cloudfront_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudFront access logs"
  value       = aws_s3_bucket.cloudfront_logs.bucket
}

output "cloudfront_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudFront access logs"
  value       = aws_s3_bucket.cloudfront_logs.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "route53_hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "route53_hosted_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = aws_route53_zone.main.name
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for general alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS topic for general alarms"
  value       = aws_sns_topic.alarms.name
}

output "backup_vault_name" {
  description = "Name of the AWS Backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault"
  value       = aws_backup_vault.main.arn
}
