resource "iosxe_interface_ethernet" "oci" {
  type                           = "GigabitEthernet"
  name                           = var.oci_interface
  description                    = "Connectivity to OCI"
  shutdown                       = false
  ip_proxy_arp                   = false
  ip_redirects                   = false
  unreachables                   = false
  ipv4_address                   = cidrhost(var.oci_interconnect_network, 1)
  ipv4_address_mask              = "255.255.255.252"

  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_interface_ethernet" "aws" {
  type                           = "GigabitEthernet"
  name                           = var.aws_interface
  description                    = "Connectivity to AWS"
  shutdown                       = false
  ip_proxy_arp                   = false
  ip_redirects                   = false
  unreachables                   = false
  ipv4_address                   = cidrhost(var.aws_interconnect_network, 1)
  ipv4_address_mask              = "255.255.255.252"

  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_bgp" "multi-cloud" {
  asn                  = "65000"
  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_bgp_neighbor" "oci" {
  asn                    = var.network_edge_asn
  ip                     = cidrhost(var.oci_interconnect_network, 2)
  remote_as              = var.drg_asn
  description            = "BGP Neighbor OCI DRG"
  shutdown               = false
  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_bgp_neighbor" "aws" {
  asn                    = var.network_edge_asn
  ip                     = cidrhost(var.aws_interconnect_network, 2)
  remote_as              = var.dxg_asn
  description            = "BGP Neighbor AWS DXG"
  shutdown               = false
  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_restconf" "bgp_password_aws" {
  path = "Cisco-IOS-XE-native:native/router/Cisco-IOS-XE-bgp:bgp=${var.network_edge_asn}/neighbor=${cidrhost(var.aws_interconnect_network, 2)}/password"
  attributes = {
    enctype = "0" # send unencrypted password to the Cisco device.  Will be encrypted in running config
    text = var.bgp_password
  }
}