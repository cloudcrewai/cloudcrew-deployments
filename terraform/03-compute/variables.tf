variable "app_image" {
  type        = string
  description = "Docker image for the application."
  default     = "nginx:latest"
}

variable "app_port" {
  type        = string
  description = "Port on which the application listens."
  default     = "80"
}

variable "certificate_domain_name" {
  type        = string
  description = "Domain name for the ACM certificate."
  default     = ""
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of ECS tasks."
  default     = 1
}

variable "ecs_max_count" {
  type        = number
  description = "Maximum number of ECS tasks for autoscaling."
  default     = 3
}

variable "ecs_task_cpu" {
  type        = string
  description = "CPU units for the ECS task."
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "Memory for the ECS task."
  default     = "512"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "health_check_path" {
  type        = string
  description = "Path for the application's health check."
  default     = "/health"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project or application."
  default     = "my-app"
}

variable "rds_free_storage_threshold_bytes" {
  type        = string
  description = "Threshold in bytes for RDS free storage alarm."
  default     = 10737418240 # 10 GB
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
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
  default     = ""
}
