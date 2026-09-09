terraform {
  backend "s3" {
    key     = "sagemaker-ml-platfor/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
