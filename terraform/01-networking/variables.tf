variable "az_count" {
  type        = number
  description = "Number of availability zones to deploy resources into."
  default = 2
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

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private application subnets, one per AZ."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_data_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private data subnets, one per AZ."
  default     = ["10.0.31.0/24", "10.0.32.0/24"]
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets, one per AZ."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
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
