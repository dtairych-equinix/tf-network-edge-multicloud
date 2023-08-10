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

resource "equinix_network_ssh_user" "multicloud" {
  username = var.ssh_user
  password = var.ssh_password
  device_ids = [
    equinix_network_device.multi-cloud-router.uuid
  ]
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
  term_length     = 1
  ssh_key {
    username = var.ssh_user
    key_name = equinix_network_ssh_key.terraform.name
  }
  acl_template_id = equinix_network_acl_template.inbound_access.uuid
}
