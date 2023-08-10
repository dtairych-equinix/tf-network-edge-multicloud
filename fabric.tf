data "equinix_ecx_l2_sellerprofile" "aws" {
  name = "AWS Direct Connect"
}

resource "equinix_ecx_l2_connection" "aws" {
  name              = "multicloud-aws-${random_string.random.result}"
  profile_uuid      = data.equinix_ecx_l2_sellerprofile.aws.uuid
  speed             = "50"
  speed_unit        = "MB"
  notifications     = ["dtairych@ap.equinix.com"]
  device_uuid         = equinix_network_device.multi-cloud-router.id
  device_interface_id = var.aws_interface
#   service_token     = equinix_metal_connection.metal-to-cloud.service_tokens.0.id
  seller_metro_code = var.network_edge_metro
  authorization_key = var.aws_account_id
  seller_region     = var.aws_region
}

data "equinix_ecx_l2_sellerprofile" "oci" {
  name = "Oracle Cloud Infrastructure -OCI- FastConnect"
}

resource "equinix_ecx_l2_connection" "oci" {
  name              = "multicloud-oci-${random_string.random.result}"
  profile_uuid      = data.equinix_ecx_l2_sellerprofile.oci.uuid
  speed             = "50"
  speed_unit        = "MB"
  notifications     = ["dtairych@ap.equinix.com"]
  device_uuid         = equinix_network_device.multi-cloud-router.id
  device_interface_id = var.oci_interface
#   service_token     = equinix_metal_connection.metal-to-cloud.service_tokens.0.id
  seller_metro_code = var.network_edge_metro
  authorization_key = oci_core_virtual_circuit.multicloud.id
#   seller_region     = var.aws_region
}