resource "oci_core_virtual_circuit" "multicloud" {
    #Required
    compartment_id = var.compartment_id
    type = var.virtual_circuit_type

    #Optional
    bandwidth_shape_name = var.virtual_circuit_bandwidth_shape_name
    # bgp_admin_state = var.virtual_circuit_bgp_admin_state # Default is enabled

    customer_asn = var.virtual_circuit_customer_asn
    customer_bgp_asn = var.virtual_circuit_customer_bgp_asn
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.virtual_circuit_display_name
    freeform_tags = {"Department"= "Finance"}
    ip_mtu = var.virtual_circuit_ip_mtu
    is_bfd_enabled = var.virtual_circuit_is_bfd_enabled
    gateway_id = oci_core_gateway.test_gateway.id
    provider_service_id = data.oci_core_fast_connect_provider_services.test_fast_connect_provider_services.fast_connect_provider_services.0.id
    provider_service_key_name = var.virtual_circuit_provider_service_key_name
    public_prefixes {
        #Required
        cidr_block = var.virtual_circuit_public_prefixes_cidr_block
    }
    region = var.virtual_circuit_region
    routing_policy = var.virtual_circuit_routing_policy
}