terraform {
  backend "s3" {
    key     = "production-three-tie/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
