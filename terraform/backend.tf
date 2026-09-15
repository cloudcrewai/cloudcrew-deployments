terraform {
  backend "s3" {
    key     = "prod-three-tier-web/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
