terraform {
  backend "s3" {
    key     = "production-three-tie/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
