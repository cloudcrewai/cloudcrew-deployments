terraform {
  backend "s3" {
    key     = "iot-data-pipeline/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
