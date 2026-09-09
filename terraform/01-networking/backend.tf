terraform {
  backend "s3" {
    key     = "sagemaker-ml-platfor/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
