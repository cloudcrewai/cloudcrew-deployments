terraform {
  backend "s3" {
    key     = "hipaa-data-governanc/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
