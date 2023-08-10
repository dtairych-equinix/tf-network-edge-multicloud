terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "1.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "equinix" {
  client_id     = var.equinix_fabric_id
  client_secret = var.equinix_fabric_secret
  auth_token    = var.equinix_metal_auth
}

provider "aws" {
  region     = var.aws_region
  secret_key = var.aws_secret
  access_key = var.aws_access
}