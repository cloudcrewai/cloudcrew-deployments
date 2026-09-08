terraform {
  backend "s3" {
    key     = "hipaa-data-platform/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
