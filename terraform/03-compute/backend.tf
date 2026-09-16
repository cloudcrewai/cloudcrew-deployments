terraform {
  backend "s3" {
    key     = "iot-data-pipeline/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
