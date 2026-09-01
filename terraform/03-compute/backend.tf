terraform {
  backend "s3" {
    key     = "hipaa-data-governanc/prod/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
