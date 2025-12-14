terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.26.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 3.1.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.6.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 3.0.1"
    }
  }
}
