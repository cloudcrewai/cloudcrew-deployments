variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days."
  default     = 365
}

variable "aurora_db_name" {
  type        = string
  description = "Name of the Aurora database."
  default     = "auroradb"
}

variable "aurora_instance_class" {
  type        = string
  description = "Instance class for Aurora DB instances."
  default     = "db.r6g.large"
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to use."
  default = 2
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for generic database instances."
  default     = "db.t3.micro"
}

variable "db_username" {
  type        = string
  description = "Username for database access."
  default     = "admin"
}

variable "elasticache_auth_token" {
  type        = string
  description = "Authentication token for ElastiCache (Redis AUTH)."
  default     = ""
  sensitive   = true
}

variable "elasticache_node_type" {
  type        = string
  description = "Node type for ElastiCache instances."
  default     = "cache.t3.micro"
}

variable "elasticache_port" {
  type        = number
  description = "Port for ElastiCache (e.g., 6379 for Redis)."
  default     = 6379
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for application logs in days."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "my-project"
}

variable "rds_mysql_db_name" {
  type        = string
  description = "Name of the RDS MySQL database."
  default     = "mysqldb"
}

variable "rds_mysql_instance_class" {
  type        = string
  description = "Instance class for RDS MySQL instances."
  default     = "db.t3.micro"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform state."
  default     = "my-terraform-state-bucket"
}
