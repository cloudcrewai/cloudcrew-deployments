variable "alb_logs_bucket_prefix" {
  type        = string
  description = "Prefix for the S3 bucket where ALB access logs will be stored."
  default     = ""
}

variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "db_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for the DB instance."
  default     = 7
}

variable "db_engine_version" {
  type        = string
  description = "The version of the database engine to use."
  default     = "14.7"
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the RDS database."
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create."
  default     = "mydb"
}

variable "db_username" {
  type        = string
  description = "The master username for the database instance."
  default     = "admin"
}

variable "elasticache_engine_version" {
  type        = string
  description = "The version number of the ElastiCache engine."
  default     = "7.1"
}

variable "elasticache_node_type" {
  type        = string
  description = "The compute and memory capacity of the nodes in the ElastiCache cluster."
  default     = "cache.t3.micro"
}

variable "elasticache_num_node_groups" {
  type        = number
  description = "The number of node groups (shards) for the ElastiCache cluster."
  default     = 1
}

variable "elasticache_replicas_per_node_group" {
  type        = number
  description = "The number of read replicas per node group for the ElastiCache cluster."
  default     = 1
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application and general logs."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
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
  description = "The S3 bucket name for Terraform remote state."
  default     = ""
}
