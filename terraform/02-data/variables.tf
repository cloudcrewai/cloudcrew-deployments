variable "alb_logs_bucket_prefix" {
  type        = string
  description = "Prefix for the S3 bucket where ALB access logs will be stored."
  default     = "alb-logs"
}

variable "db" {
  type        = string
  description = "Name of the database."
  default     = "mydb"
}

variable "db_allocated_storage" {
  type        = number
  description = "The amount of allocated storage (in gigabytes) for the DB instance."
  default     = 20
}

variable "db_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for."
  default     = 7
}

variable "db_cluster_parameter_group_family" {
  type        = string
  description = "The family of the DB cluster parameter group."
  default     = "aurora-postgresql15"
}

variable "db_engine" {
  type        = string
  description = "The database engine to use."
  default     = "postgres"
}

variable "db_engine_version" {
  type    = string
  description = "The version of the database engine to use."
  default = "15.5"
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the DB instance."
  default     = "db.t3.micro"
}

variable "db_parameter_group_family" {
  type        = string
  description = "The family of the DB parameter group."
  default     = "postgres15"
}

variable "db_preferred_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if automated backups are enabled."
  default     = "03:00-04:00"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user."
  default     = "admin"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
  default     = "dev"
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
  description = "A map of tags to assign to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform remote state."
  default     = "my-tf-state-bucket"
}
