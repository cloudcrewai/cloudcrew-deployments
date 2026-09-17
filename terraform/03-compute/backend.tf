terraform {
  backend "s3" {
    key     = "ai-agent-platform/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
