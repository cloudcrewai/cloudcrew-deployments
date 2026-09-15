variable "acm_domain" {
  type        = string
  description = "The domain name for the ACM certificate."
  default     = ""
}

variable "alb_drop_invalid_header_fields" {
  type        = bool
  description = "Indicates whether HTTP headers with invalid field names or values are dropped."
  default     = false
}

variable "alb_enable_deletion_protection" {
  type        = bool
  description = "If true, deletion of the load balancer will be disabled via the AWS API."
  default     = false
}

variable "alb_scheme" {
  type        = string
  description = "The scheme for the ALB. Can be 'internet-facing' or 'internal'."
  default     = "internet-facing"
}

variable "cloudwatch_logs_kms_key_description" {
  type        = string
  description = "Description for the KMS key used for CloudWatch Logs encryption."
  default     = ""
}

variable "ecr_image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Can be 'MUTABLE' or 'IMMUTABLE'."
  default     = "MUTABLE"
}

variable "ecs_container_port" {
  type        = number
  description = "The port on the container to expose."
  default     = 80
}

variable "ecs_cpu_alarm_comparison_operator" {
  type        = string
  description = "The comparison operator for the ECS CPU utilization alarm."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "ecs_cpu_alarm_metric_name" {
  type        = string
  description = "The metric name for the ECS CPU utilization alarm."
  default     = "CPUUtilization"
}

variable "ecs_cpu_alarm_threshold" {
  type        = number
  description = "The threshold for the ECS CPU utilization alarm."
  default     = 80
}

variable "ecs_cpu_target_utilization" {
  type        = number
  description = "The target CPU utilization percentage for ECS auto-scaling."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of ECS tasks."
  default     = 2
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of ECS tasks for auto-scaling."
  default     = 4
}

variable "ecs_memory_alarm_comparison_operator" {
  type        = string
  description = "The comparison operator for the ECS memory utilization alarm."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "ecs_memory_alarm_metric_name" {
  type        = string
  description = "The metric name for the ECS memory utilization alarm."
  default     = "MemoryUtilization"
}

variable "ecs_memory_alarm_threshold" {
  type        = number
  description = "The threshold for the ECS memory utilization alarm."
  default     = 80
}

variable "ecs_memory_target_utilization" {
  type        = number
  description = "The target memory utilization percentage for ECS auto-scaling."
  default     = 70
}

variable "ecs_min_capacity" {
  type        = number
  description = "The minimum number of ECS tasks for auto-scaling."
  default     = 2
}

variable "ecs_task_cpu" {
  type        = string
  description = "The number of CPU units reserved for the container. Can be '256', '512', '1024', etc."
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "The amount of memory (in MiB) reserved for the container. Can be '512', '1024', '2048', etc."
  default     = "512"
}

variable "elasticache_kms_key_description" {
  type        = string
  description = "Description for the KMS key used for ElastiCache encryption."
  default     = ""
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch Logs."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
}

variable "rds_kms_key_description" {
  type        = string
  description = "Description for the KMS key used for RDS encryption."
  default     = ""
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "route53_hosted_zone" {
  type        = string
  description = "The Route53 hosted zone name for DNS records."
  default     = ""
}

variable "s3_alb_logs_kms_key_description" {
  type        = string
  description = "Description for the KMS key used for S3 ALB logs encryption."
  default     = ""
}

variable "secrets_manager_kms_key_description" {
  type        = string
  description = "Description for the KMS key used for Secrets Manager encryption."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = ""
}

variable "waf_rate_limit_threshold" {
  type        = number
  description = "The maximum number of requests per 5-minute period for a WAF rate-based rule."
  default     = 2000
}

variable "waf_scope" {
  type        = string
  description = "The scope of the WAFv2 Web ACL. Can be 'CLOUDFRONT' or 'REGIONAL'."
  default     = "CLOUDFRONT"
}
