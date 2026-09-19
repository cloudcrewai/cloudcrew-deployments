terraform {
  backend "s3" {
    key     = "production-three-tie/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
