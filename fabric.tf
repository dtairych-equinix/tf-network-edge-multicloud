data "equinix_ecx_l2_sellerprofile" "clouds" {
  for_each = var.clouds
  name = each.value.fabric_profile
}

resource "equinix_ecx_l2_connection" "clouds" {
  for_each = var.clouds
  name              = "multicloud-${each.key}-${random_string.random.result}"
  profile_uuid      = data.equinix_ecx_l2_sellerprofile.clouds[each.key].uuid
  speed             = each.value.speed
  speed_unit        = "MB"
  notifications     = var.equinix_fabric_users
  device_uuid         = equinix_network_device.multi-cloud-router.id
  device_interface_id = each.value.ne_interface
  seller_metro_code = var.network_edge_metro
  authorization_key = var.cloud_auth_keys[each.key].key
  seller_region     = each.value.region
}