resource "oci_core_security_list" "output" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "out"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "ssh" {
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

resource "oci_core_security_list" "web" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "web"

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = true

    tcp_options {
      min = "80"
      max = "80"
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = true

    tcp_options {
      min = "443"
      max = "443"
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = true

    tcp_options {
      min = "8000"
      max = "8000"
    }
  }
}

resource "oci_core_security_list" "kafka" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "kafka"

  ingress_security_rules {
    protocol  = "6"
    source    = oci_core_virtual_network.vcn.cidr_block
    stateless = true

    tcp_options {
      min = "9092"
      max = "9092"
    }
  }
}

resource "oci_core_security_list" "ping" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "ping"

  ingress_security_rules {
    protocol = "1"
    source   = var.home_wan_subnet

    icmp_options {
      type = 8
    }
  }
}

resource "oci_core_security_list" "mosh" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "mosh"

  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"

    udp_options {
      min = "60000"
      max = "61000"
    }
  }
}

resource "oci_core_security_list" "wireguard" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "wireguard"

  ingress_security_rules {
    protocol  = "17"
    source    = "0.0.0.0/0"
    stateless = false

    udp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      min = "443"
      max = "443"
    }
  }

  ingress_security_rules {
    protocol  = "1"
    source    = "0.0.0.0/0"
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }
}
