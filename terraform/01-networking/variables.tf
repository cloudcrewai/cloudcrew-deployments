variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to deploy resources into."
  default = 1
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for application and general logs in days."
  default     = 90
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets, one per AZ."
  default     = ["10.0.11.0/24"]
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets, one per AZ."
  default     = ["10.0.1.0/24"]
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

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "log_bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete audit-log buckets (CloudTrail access logs, AWS Config delivery) that still hold objects. Keep false to protect the audit trail; set true only for a deliberate teardown."
  default     = false
}
