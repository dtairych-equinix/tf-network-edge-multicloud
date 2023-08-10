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


resource "tls_private_key" "multi-cloud" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

provider "equinix" {
  client_id     = var.equinix_fabric_id
  client_secret = var.equinix_fabric_secret
  auth_token    = var.equinix_metal_auth
}

data "equinix_network_account" "multicloud" {
  name = var.equinix_fabric_account_name
  metro_code = var.network_edge_metro
}

resource "equinix_network_acl_template" "inbound_access" {
  name        = "multi-cloud"
  description = "ACL used for Equinix/Oracle multi-cloud demo"
  inbound_rule {
    subnet  = "0.0.0.0/0"
    protocol = "IP"
    src_port = "any"
    dst_port = "any"
  }
}

resource "equinix_network_ssh_key" "terraform" {
  name       = "multi-cloud-terraform"
  public_key = tls_private_key.multi-cloud.public_key_openssh

}



resource "equinix_network_device" "multi-cloud-router" {
  name            = "tf-multi-cloud"
  metro_code      = data.equinix_network_account.multicloud.metro_code
  type_code       = var.network_edge_device_type
  self_managed    = true
  byol            = true
  package_code    = "network-essentials"
  notifications   = [var.equinix_fabric_user]
  hostname        = "mc-router"
  account_number  = data.equinix_network_account.multicloud.number
  version         = "17.06.01a"
  core_count      = 2
  term_length     = 12
  ssh_key {
    username = var.ssh_user
    key_name = equinix_network_ssh_key.terraform.name
  }
  acl_template_id = equinix_network_acl_template.inbound_access.uuid
}

# resource "equinix_network_ssh_user" "multicloud" {
#   username = var.ssh_user
#   password = var.ssh_password
#   device_ids = [
#     equinix_network_device.multi-cloud-router.uuid
#   ]
# }

# provider "aws" {
#   region     = var.aws_region
#   secret_key = var.secret_key
#   access_key = var.access_key
# }

# provider "oci" {
#     auth = var.oci_auth
#     region = var.oci_region
# }

resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
}



# data "aws_dx_connection" "example" {
#   name = equinix_ecx_l2_connection.metal-to-cloud.name
# } 

# resource "aws_dx_private_virtual_interface" "foo" {
#   connection_id    = data.aws_dx_connection.example.id
#   name             = "private-vif"
#   vlan             = equinix_ecx_l2_connection.metal-to-cloud.zside_vlan_stag
#   address_family   = "ipv4"
#   amazon_address   = "192.168.100.2/30"
#   customer_address = "192.168.100.1/30"
#   bgp_asn          = 65000
#   vpn_gateway_id   = aws_vpn_gateway.vpn_gw.id
#   bgp_auth_key     = var.bgp_psswd
#   depends_on = [
#     data.aws_dx_connection.example,
#     aws_dx_connection_confirmation.confirmation
#   ]
# }

# resource "aws_dx_connection_confirmation" "confirmation" {
#   connection_id = data.aws_dx_connection.example.id
# }



data "equinix_ecx_l2_sellerprofile" "aws" {
  name = "AWS Direct Connect"
}

# resource "equinix_ecx_l2_connection" "metal-to-cloud" {
#   name              = "metal-to-cloud-${random_string.random.result}"
#   profile_uuid      = data.equinix_ecx_l2_sellerprofile.aws.uuid
#   speed             = "50"
#   speed_unit        = "MB"
#   notifications     = ["dtairych@ap.equinix.com"]
#   service_token     = equinix_metal_connection.metal-to-cloud.service_tokens.0.id
#   seller_metro_code = upper(var.deployment_metro)
#   authorization_key = var.aws_account
#   seller_region     = var.aws_region
# }

data "equinix_ecx_l2_sellerprofile" "oci" {
  name = "Oracle Cloud Infrastructure -OCI- FastConnect"
}

resource "local_file" "rsa_private_key" {
  content         = tls_private_key.multi-cloud.private_key_openssh
  filename        = "rsa_private_key"
  file_permission = "0600"
}

resource "local_file" "ios_restconf" {
  filename = "ciscoIOS.exp"
  content = templatefile(
    "./ciscoIOS.tftpl",
    {
      ssh_user = var.ssh_user
      ssh_password = var.ssh_password
      ne_ip = equinix_network_device.multi-cloud-router.ssh_ip_address
      hostname = equinix_network_device.multi-cloud-router.hostname
    }
  )
}

resource "null_resource" "exec_restconf" {
  provisioner "local-exec" {
    command = "expect ciscoIOS.exp"
  }
  depends_on = [ 
    local_file.ios_restconf,
    equinix_network_device.multi-cloud-router
  ]
}

provider "iosxe" {
  // Required but Optional if env variable are set
  url = "https://${equinix_network_device.multi-cloud-router.ssh_ip_address}"
  username = var.ssh_user
  password = var.ssh_password
  // Optional Parameters
  insecure = true
}

resource "iosxe_restconf" "bgp_password_aws" {
  path = "Cisco-IOS-XE-native:native/router/Cisco-IOS-XE-bgp:bgp=${var.network_edge_asn}/neighbor=${cidrhost(var.aws_interconnect_network, 2)}/password"
  attributes = {
    enctype = "5" # This is the encapsulation type for an MD5 encoded password
    text = md5(var.bgp_password)
  }
}


# data "iosxe_restconf" "example" {
#   path = "Cisco-IOS-XE-native:native/router/Cisco-IOS-XE-bgp:bgp=65000/neighbor=192.168.4.2/password"
# }


# output "restconf" {
#   value = data.iosxe_restconf.example.attributes
# }

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
  # default_ipv4_unicast = false
  # log_neighbor_changes = true
  # router_id_loopback   = 100

  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_bgp_neighbor" "oci" {
  asn                    = var.network_edge_asn
  ip                     = cidrhost(var.oci_interconnect_network, 2)
  remote_as              = var.drg_asn
  description            = "BGP Neighbor OCI DRG"
  shutdown               = false
  # update_source_loopback = "100"

  depends_on = [ null_resource.exec_restconf ]
}

resource "iosxe_bgp_neighbor" "aws" {
  asn                    = var.network_edge_asn
  ip                     = cidrhost(var.aws_interconnect_network, 2)
  remote_as              = var.dxg_asn
  description            = "BGP Neighbor AWS DXG"
  shutdown               = false
  # update_source_loopback = "100"

  depends_on = [ null_resource.exec_restconf ]
}