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

variable "db_username" {
  type    = string
  default = "admin"
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

variable "log_bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete audit-log buckets (CloudTrail access logs, AWS Config delivery) that still hold objects. Keep false to protect the audit trail; set true only for a deliberate teardown."
  default     = false
}
