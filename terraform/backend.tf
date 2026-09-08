terraform {
  backend "s3" {
    key     = "production-vpc-rds/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
