terraform {
  backend "s3" {
    key     = "iot-data-pipeline/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
