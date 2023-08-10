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
    oci = {
      source = "oracle/oci"
      version = "5.3.0"
    }
    iosxe = {
      source = "CiscoDevNet/iosxe"
      version = "0.3.2"
    }
  }
}

provider "equinix" {
  client_id     = var.equinix_fabric_id
  client_secret = var.equinix_fabric_secret
  auth_token    = var.equinix_metal_auth
}

# provider "oci" {
#     auth = var.oci_auth
#     region = var.oci_region
# }


provider "aws" {
  region     = var.aws_region
  secret_key = var.aws_secret
  access_key = var.aws_access
}


provider "iosxe" {
  url = "https://${equinix_network_device.multi-cloud-router.ssh_ip_address}"
  username = var.ssh_user
  password = var.ssh_password
  insecure = true
}