terraform {
  backend "s3" {
    key     = "production-three-tie/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
