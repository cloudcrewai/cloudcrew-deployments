variable "alb_sg_name" {
  type    = string
  default = ""
}

variable "app_sg_name" {
  type    = string
  default = ""
}

variable "audit_log_retention_days" {
  type    = number
  default = 365
}

variable "az_count" {
  type    = number
  default = 2
}

variable "cloudtrail_s3_bucket_name" {
  type    = string
  default = ""
}

variable "config_s3_bucket_name" {
  type    = string
  default = ""
}

variable "database_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "db_sg_name" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  type    = string
  default = ""
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
