data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "production-vpc-rds/prod/01-networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "production-vpc-rds/prod/02-data/terraform.tfstate"
    region = "us-east-1"
  }
}
