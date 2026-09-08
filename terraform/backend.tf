terraform {
  backend "s3" {
    key     = "data-platform/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
