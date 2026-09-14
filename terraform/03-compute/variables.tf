variable "app_domain_name" {
  type        = string
  description = "The application's domain name."
  default     = ""
}

variable "db_identifier" {
  type        = string
  description = "Identifier for the database instance."
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "The base domain name for the project."
  default     = ""
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of tasks for the ECS service."
  default     = 3
}

variable "ecs_min_capacity" {
  type        = number
  description = "The minimum number of tasks for the ECS service."
  default     = 1
}

variable "ecs_task_cpu" {
  type    = string
  description = "The CPU units for the ECS task (e.g., '256', '512', '1024')."
  default     = "256"
}

variable "ecs_task_memory" {
  type    = string
  description = "The memory units for the ECS task (e.g., '512', '1024', '2048')."
  default     = "512"
}

variable "elasticache_cluster_id" {
  type        = string
  description = "Identifier for the ElastiCache cluster."
  default     = ""
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., 'dev', 'staging', 'prod')."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = ""
}

variable "rds_free_storage_threshold_bytes" {
  type        = string
  description = "The threshold in bytes for free storage on RDS before an alert is triggered."
  default     = 10737418240 # 10 GB
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
  description = "The S3 bucket name for Terraform state."
  default     = ""
}
