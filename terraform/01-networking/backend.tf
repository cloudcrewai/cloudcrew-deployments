terraform {
  backend "s3" {
    key     = "production-vpc-rds/prod/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
