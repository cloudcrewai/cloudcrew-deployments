terraform {
  backend "s3" {
    key     = "hipaa-data-platform/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
