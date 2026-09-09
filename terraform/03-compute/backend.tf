terraform {
  backend "s3" {
    key     = "sagemaker-ml-platfor/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
