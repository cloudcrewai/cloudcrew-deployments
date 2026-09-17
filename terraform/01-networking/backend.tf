terraform {
  backend "s3" {
    key     = "ai-agent-platform/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
