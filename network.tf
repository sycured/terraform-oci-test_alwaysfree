resource "oci_core_virtual_network" "vcn" {
  cidr_block     = "10.100.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "vcn"
  dns_label      = "vcn"
}

resource "oci_core_subnet" "subnet" {
  compartment_id    = var.compartment_ocid
  cidr_block        = "10.100.10.0/24"
  display_name      = "subvcn"
  dns_label         = "subvcn"
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  route_table_id    = oci_core_route_table.route_table.id
  security_list_ids = [oci_core_security_list.security_list_out.id, oci_core_security_list.security_list_ssh.id, oci_core_security_list.security_list_web.id]
  vcn_id            = oci_core_virtual_network.vcn.id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "IG"
  vcn_id         = oci_core_virtual_network.vcn.id
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}