variable "app_port" {
  type        = number
  description = "The port on which the application listens."
  default     = 8080
}

variable "az_count" {
  type        = number
  description = "Number of availability zones to deploy into."
  default = 2
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the database subnets."
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch."
  default     = 90
}

variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit-relevant logs in CloudWatch (e.g., CloudTrail)."
  default     = 365
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the private application subnets."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-app"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}
