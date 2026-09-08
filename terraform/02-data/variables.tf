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

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = "my-terraform-state-bucket-12345"
}
