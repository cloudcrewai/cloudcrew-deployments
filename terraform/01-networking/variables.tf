variable "az_count" {
  type        = number
  description = "Number of availability zones to deploy resources into."
  default = 2
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the database subnets."
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
  default     = 90
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the private subnets."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
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
