variable "az_count" {
  type    = number
  default = 2
}

variable "db_backup_retention_period" {
  type    = number
  default = 7
}

variable "db_engine_version" {
  type    = string
  default = "15.5"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_parameter_group_family" {
  type    = string
  default = "postgres15"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "elasticache_engine_version" {
  type    = string
  default = "7.0"
}

variable "elasticache_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "elasticache_num_cache_clusters" {
  type    = number
  default = 1
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "s3_alb_logs_bucket_prefix" {
  type    = string
  default = "alb-logs"
}

variable "s3_assets_bucket_prefix" {
  type    = string
  default = "assets"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = "my-tf-state-bucket"
}
