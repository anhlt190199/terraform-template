terraform {
  required_version = ">= 1.0.3"
  backend "s3" {
    region  = "us-east-2"
    bucket  = "anhlt-dev-state"
    key     = "terraform.tfstate"
    encrypt = false
    profile = "anhlt-devops"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.52.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }

    null       = ">= 3.1.0"
    template   = ">= 2.2.0"
    kubernetes = ">= 2.17.0"
    helm       = ">= 2.8.0"
  }
}