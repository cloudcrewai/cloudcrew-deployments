terraform {
  backend "s3" {
    key     = "production-serverles/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
