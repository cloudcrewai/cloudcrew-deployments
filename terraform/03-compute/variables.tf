variable "alb_5xx_alarm_threshold" {
  type    = number
  default = 5
}

variable "alb_listener_port_http" {
  type    = number
  default = 80
}

variable "alb_listener_port_https" {
  type    = number
  default = 443
}

variable "alb_name" {
  type    = string
  default = "my-app-alb"
}

variable "alb_target_group_name" {
  type    = string
  default = "my-app-tg"
}

variable "api_gateway_name" {
  type    = string
  default = "my-app-api"
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "cloud_map_namespace_name" {
  type    = string
  default = "my-app-namespace"
}

variable "cloud_map_service_name" {
  type    = string
  default = "my-app-service"
}

variable "cloudwatch_dashboard_name" {
  type    = string
  default = "my-app-dashboard"
}

variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "ecr_repository_name" {
  type    = string
  default = "my-app-repo"
}

variable "ecs_cluster_name" {
  type    = string
  default = "my-app-cluster"
}

variable "ecs_cpu_alarm_threshold" {
  type    = number
  default = 70
}

variable "ecs_desired_count" {
  type    = number
  default = 2
}

variable "ecs_service_name" {
  type    = string
  default = "my-app-service"
}

variable "ecs_task_cpu" {
  type    = number
  default = 256
}

variable "ecs_task_memory" {
  type    = number
  default = 512
}

variable "elasticache_cpu_alarm_threshold" {
  type    = number
  default = 70
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "kms_app_key_description" {
  type    = string
  default = "KMS key for application data"
}

variable "kms_logs_key_description" {
  type    = string
  default = "KMS key for general logs"
}

variable "kms_s3_alb_logs_key_description" {
  type    = string
  default = "KMS key for S3 ALB access logs"
}

variable "lambda_rotation_function_name" {
  type    = string
  default = "my-app-rotation-function"
}

variable "lambda_rotation_role_name" {
  type    = string
  default = "my-app-rotation-role"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "mfa_alarm_threshold" {
  type    = number
  default = 1
}

variable "project_name" {
  type    = string
  default = "my-app"
}

variable "rds_cpu_alarm_threshold" {
  type    = number
  default = 70
}

variable "rds_free_storage_alarm_threshold" {
  type    = number
  default = 20
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "root_usage_alarm_threshold" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = "my-tf-state-bucket"
}

variable "unauthorized_api_alarm_threshold" {
  type    = number
  default = 5
}

variable "waf_web_acl_name" {
  type    = string
  default = "my-app-waf-acl"
}
