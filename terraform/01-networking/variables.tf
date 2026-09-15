variable "alb_port_http" {
  type    = number
  default = 80
}

variable "alb_port_https" {
  type    = number
  default = 443
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "audit_log_retention_days" {
  type    = number
  default = 365
}

variable "az_count" {
  type    = number
  default = 2
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "elasticache_port" {
  type    = number
  default = 6379
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "log_bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete audit-log buckets (CloudTrail access logs, AWS Config delivery) that still hold objects. Keep false to protect the audit trail; set true only for a deliberate teardown."
  default     = false
}
