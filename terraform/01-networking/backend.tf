terraform {
  backend "s3" {
    key     = "aurora-serverless-v2/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
