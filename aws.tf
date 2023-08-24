data "aws_dx_gateway" "multicloud" {
  name = var.aws_dxg_name
}

data "aws_dx_connection" "example" {
  name = equinix_ecx_l2_connection.clouds["AWS"].name
} 

resource "aws_dx_private_virtual_interface" "multicloud" {
  connection_id    = data.aws_dx_connection.example.id
  name             = "private-vif"
  vlan             = equinix_ecx_l2_connection.clouds["AWS"].zside_vlan_stag
  address_family   = "ipv4"
  amazon_address   = "${cidrhost(var.clouds["AWS"].interconnect_network, 2)}/30"
  customer_address = "${cidrhost(var.clouds["AWS"].interconnect_network, 1)}/30"
  bgp_asn          = 65000
  dx_gateway_id = data.aws_dx_gateway.multicloud.id
  bgp_auth_key     = var.clouds["AWS"].bgp_password
  depends_on = [
    data.aws_dx_connection.example,
    aws_dx_connection_confirmation.confirmation
  ]
}

resource "aws_dx_connection_confirmation" "confirmation" {
  connection_id = data.aws_dx_connection.example.id
}