provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.env
      Stack       = "bootstrap"
      ManagedBy   = "terraform"
    }
  }
}
