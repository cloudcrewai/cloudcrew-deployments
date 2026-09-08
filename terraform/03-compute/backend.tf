terraform {
  backend "s3" {
    key     = "aurora-serverless-v2/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
