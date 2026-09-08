terraform {
  backend "s3" {
    key     = "aurora-serverless-v2/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
