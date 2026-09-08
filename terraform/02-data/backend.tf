terraform {
  backend "s3" {
    key     = "production-vpc-rds/prod/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
