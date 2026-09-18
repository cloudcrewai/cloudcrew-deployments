variable "alb_5xx_error_threshold" {
  type        = number
  description = "Threshold for ALB 5xx errors to trigger an alarm."
  default     = 5
}

variable "alb_response_time_threshold_seconds" {
  type        = number
  description = "Threshold for ALB response time in seconds to trigger an alarm."
  default     = 5
}

variable "app_health_check_path" {
  type        = string
  description = "Path for the application health check."
  default     = "/health"
}

variable "app_port" {
  type        = number
  description = "Port on which the application is listening."
  default     = 80
}

variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "cross_region_copy_region" {
  type        = string
  description = "AWS region to copy resources (e.g., AMIs, snapshots) to for disaster recovery."
  default     = "us-west-2"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application (e.g., example.com)."
  default     = "example.com"
}

variable "ecs_cpu_utilization_threshold" {
  type        = number
  description = "Threshold for ECS service CPU utilization to trigger scaling or alarms."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of tasks for the ECS service autoscaling."
  default     = 3
}

variable "ecs_min_capacity" {
  type        = number
  description = "The minimum number of tasks for the ECS service autoscaling."
  default     = 1
}

variable "ecs_task_cpu" {
  type        = number
  description = "The CPU units for the ECS task (e.g., 256, 512, 1024)."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "The memory in MiB for the ECS task (e.g., 512, 1024, 2048)."
  default     = 512
}

variable "elasticache_cpu_utilization_threshold" {
  type        = number
  description = "Threshold for ElastiCache CPU utilization to trigger an alarm."
  default     = 70
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application and general logs in CloudWatch."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-project"
}

variable "rds_cpu_utilization_threshold" {
  type        = number
  description = "Threshold for RDS CPU utilization to trigger an alarm."
  default     = 70
}

variable "rds_free_storage_threshold_bytes" {
  type        = string
  description = "Threshold for RDS free storage in bytes to trigger an alarm."
  default     = 10737418240 # 10 GB
}

variable "redis_auth_token_rotation_frequency_days" {
  type    = string
  description = "Frequency in days for rotating Redis AUTH tokens."
  default     = 90
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = "my-tf-state-bucket-12345"
}

variable "waf_rate_based_rule_threshold" {
  type        = number
  description = "The threshold for WAF rate-based rules (requests per 5 minutes)."
  default     = 2000
}
