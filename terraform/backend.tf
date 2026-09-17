terraform {
  backend "s3" {
    key     = "ai-agent-platform/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
