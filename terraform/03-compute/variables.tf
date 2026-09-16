variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days."
  default     = 365
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "lambda_processor_memory_mb" {
  type        = number
  description = "Memory allocated to the Lambda processor function in MB."
  default     = 128
}

variable "lambda_processor_reserved_concurrency" {
  type        = number
  description = "The amount of reserved concurrency for the Lambda processor function. Set to 0 for unreserved."
  default     = 0
}

variable "lambda_processor_timeout" {
  type        = number
  description = "Timeout for the Lambda processor function in seconds."
  default     = 30
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for application and general logs in days."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
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
  description = "The S3 bucket name used for Terraform state."
  default     = ""
}

variable "timestream_database_name" {
  type        = string
  description = "Name for the Timestream database."
  default     = "my-timestream-db"
}

variable "timestream_magnetic_retention_days" {
  type        = number
  description = "Retention period for magnetic storage in Timestream in days."
  default     = 365
}

variable "timestream_memory_retention_hours" {
  type        = number
  description = "Retention period for memory storage in Timestream in hours."
  default     = 24
}

variable "timestream_table_name" {
  type        = string
  description = "Name for the Timestream table."
  default     = "my-timestream-table"
}

variable "log_bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete audit-log buckets (CloudTrail access logs, AWS Config delivery) that still hold objects. Keep false to protect the audit trail; set true only for a deliberate teardown."
  default     = false
}
