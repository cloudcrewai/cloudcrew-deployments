variable "app_port" {
  type    = number
  default = 80
}

variable "az_count" {
  type    = number
  default = 2
}

variable "database_subnet_cidrs" {
  type    = list(string)
  default = ["172.16.21.0/24", "172.16.22.0/24"]
}

variable "db_port" {
  type    = number
  default = 5432
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
  default = ["172.16.11.0/24", "172.16.12.0/24"]
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["172.16.1.0/24", "172.16.2.0/24"]
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/16"
}
