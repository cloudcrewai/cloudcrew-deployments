variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to use for the VPC and subnets."
  default = 2
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the database subnets, one per AZ."
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT Gateways in public subnets for outbound internet access from private subnets."
  default     = false
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application and general logs."
  default     = 90
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the private subnets, one per AZ."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets, one per AZ."
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
