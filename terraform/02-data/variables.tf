variable "audit_log_retention_days" {
  type    = number
  default = 365
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Password for the database user."
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "elasticache_auth_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Authentication token for ElastiCache (if enabled)."
}

variable "elasticache_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = "my-terraform-state-bucket"
}

variable "db_secret_rotation_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function for database secret rotation."
  default     = ""
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "Security group ID for VPC endpoints."
  default     = ""
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "List of private route table IDs for VPC Gateway endpoints."
  default     = []
}
