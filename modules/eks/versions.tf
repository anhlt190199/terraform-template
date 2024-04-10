terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }

    template   = ">= 2.2.0"
    kubernetes = ">= 2.17.0"
    helm       = ">= 2.8.0"
  }
}
