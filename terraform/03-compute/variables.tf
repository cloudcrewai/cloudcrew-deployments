variable "alb_response_time_threshold" {
  type        = number
  description = "Threshold for ALB response time in seconds."
  default     = 5
}

variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "dr_region" {
  type        = string
  description = "AWS region for disaster recovery."
  default     = "us-west-2"
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of ECS tasks."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "Maximum capacity for ECS service auto-scaling."
  default     = 3
}

variable "ecs_min_capacity" {
  type        = number
  description = "Minimum capacity for ECS service auto-scaling."
  default     = 1
}

variable "ecs_task_cpu" {
  type        = string
  description = "CPU units for the ECS task."
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "Memory (in MiB) for the ECS task."
  default     = "512"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application and container logs."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project or application."
  default     = "my-project"
}

variable "rds_cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for RDS alerts."
  default     = 75
}

variable "region" {
  type        = string
  description = "AWS region where resources will be deployed."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform state."
  default     = "my-terraform-state-bucket"
}
