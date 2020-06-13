resource "oci_core_security_list" "security_list_out" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "out"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "security_list_ssh" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "ssh"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = "22"
      max = "22"
    }
  }
}

resource "oci_core_security_list" "security_list_web" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "web"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    stateless = true

    tcp_options {
      min = "80"
      max = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    stateless = true

    tcp_options {
      min = "443"
      max = "443"
    }
  }
}