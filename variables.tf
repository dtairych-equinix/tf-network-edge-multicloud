
##### Equinix Variables ##########

variable "equinix_fabric_account_name" {
  description = "Name of the Equinix Fabric account (optional).  Useful if customer has multiple Equinix Fabric accounts in a given Metro"
  type = string
  sensitive = true
}

variable "equinix_fabric_id" {
    description = "Equinix Fabric client id for API access"
  type      = string
  sensitive = true
}

variable "equinix_fabric_secret" {
    description = "Equinix Fabric client secret for API access"
  type      = string
  sensitive = true
}

variable "equinix_fabric_user" {
  description = "Username of Equinix Fabric account which will be used for all notifications"
  type = string
  sensitive = true
}

variable "network_edge_device_type" {
  description = "The VNF to deploy on Network Edge.  Please note: Only validated for Catalyst 8K Autonomous mode"
  type = string
  default = "C8000V"
}

variable "equinix_metal_auth" {
    description = "Equinix Metal authentication token for API access"
    type = string
    sensitive = true
}

variable "network_edge_metro" {
  description = "The metro in which you want to deploy the Equinix Network Edge Device"
  type = string
  default = "FR"
}

variable "deployment_metro" {
  type    = string
  default = "fr"
}

# variable "oci_auth" {
#     description = "Oracle Cloud authentication token for API access"
#   type = string
#   sensitive = true
# }

# variable "oci_drg_id" {
#   description = "OCID of the Oracle Cloud DRG to connect to"
#   type = string
#   sensitive = true
# }

variable "oci_compartment_id" {
  description = "The Compartment ID for all the Oracle Cloud resources"
  type = string
  sensitive = true
}

#######  AWS Variables #########

variable "aws_dxg_name" {
  type = string
  sensitive = true
}

variable "ssh_user" {
  type = string
  sensitive = true
}

variable "ssh_password" {
  type = string
  sensitive = true 
}

variable "oci_interface" {
  description = "Interface on the Network Edge device to connect the OCI FastConnect to"
  type = string
  default = "3"
}

variable "aws_interface" {
  description = "Interface on the Network Edge device to connect the AWS Direct Connect to"
  type = string
  default = "4"
}

variable "oci_interconnect_network" {
  description = "Network that will be used to interconnect Network Edge to Oracle (Fastconnect).  Must be a /30"
  type = string
  default = "192.168.3.0/30"

}

variable "aws_interconnect_network" {
  description = "Network that will be used to interconnect Network Edge to AWS (Direct Connect).  Must be a /30"
  type = string
  default = "192.168.4.0/30"
}

variable "aws_account_id" {
  description = "The account ID of the AWS tenancy that the DXG is created in"
  type      = string
  sensitive = true
}

variable "aws_region" {
  description = "The AWS region in which the resources are deployed"
  type    = string
  default = "eu-central-1"
}

variable "aws_access" {
  type      = string
  sensitive = true
}

variable "aws_secret" {

  type      = string
  sensitive = true
}

variable "bgp_password" {
  type = string
  sensitive = true
}

variable "drg_asn" {
  description = "ASN of the Oracle Cloud DRG"
  type = string
  default = "31898"
}

variable "dxg_asn" {
  description = "ASN of the AWS Private VIF"
  type = string
  default = "64512"
}

variable "network_edge_asn" {
  description = "ASN of the Equinix Network Edge device"
  type = string
  default = "65000"
}

variable "clouds" {
  description = "A collection of the various multi-cloud environments that will be connected"
  type = map(any)
  default = {
    AWS = {
      name = "AWS"
      fabric_profile = "AWS Direct Connect"
      speed = "50"
      ne_interface = 4
      interconnect_network = "192.168.4.0/30"
      interface_ip = "192.168.4.1/30"
      remote_ip = "192.168.4.2/30"
      remote_asn = 65412
      bgp_password = "test_password"
      region = "eu-central-1"
    },
    OCI = {
      name = "OCI"
      fabric_profile = "Oracle Cloud Infrastructure -OCI- FastConnect"
      speed = 50
      ne_interface = 3
      interconnect_network = "192.168.3.0/30"
      interface_ip = "192.168.3.1/30"
      remote_ip = "192.168.3.2/30"
      remote_asn = 31898
      bgp_password = "test_password"
      region = ""
    }
  }
}

variable "cloud_auth_keys" {
  description = "Variable to hold the different auths for cloud providers on Equinix Fabric"
  sensitive = true
  type = map(any)
}