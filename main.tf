provider "oci" {
  version          = "~> 3.65"
  fingerprint      = var.fingerprint
  private_key_path = pathexpand(var.private_key_path)
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}

# GET availability domain
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# GET image id for latest Oracle Linux image for specified major version or fallback to default = 8
data "oci_core_app_catalog_listings" "oracle-linux_listings" {
  publisher_name = "Oracle Linux"
  filter {
    name   = "display_name"
    values = ["^Oracle Linux ${var.os_major_version}.([\\.0-9-]+)$"]
    regex  = true
  }
}

data "oci_core_app_catalog_listing_resource_versions" "AppCatalog-Oracle-Linux" {
  listing_id = lookup(data.oci_core_app_catalog_listings.oracle-linux_listings.app_catalog_listings[0], "listing_id")
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "oracle-linux_agreement" {
  listing_id               = lookup(data.oci_core_app_catalog_listing_resource_versions.AppCatalog-Oracle-Linux.app_catalog_listing_resource_versions[0], "listing_id")
  listing_resource_version = lookup(data.oci_core_app_catalog_listing_resource_versions.AppCatalog-Oracle-Linux.app_catalog_listing_resource_versions[0], "listing_resource_version")
}

resource "oci_core_app_catalog_subscription" "oracle-linux_subscription" {
  compartment_id           = var.tenancy_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.oracle-linux_agreement.time_retrieved

  timeouts {
    create = "20m"
  }
}

data "oci_core_app_catalog_subscriptions" "oracle-linux_subscriptions" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  listing_id = oci_core_app_catalog_subscription.oracle-linux_subscription.listing_id

  filter {
    name   = "listing_resource_version"
    values = ["${oci_core_app_catalog_subscription.oracle-linux_subscription.listing_resource_version}"]
  }
}

# define private network
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

# define internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "IG"
  vcn_id         = oci_core_virtual_network.vcn.id
}

#define route table
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
      max = "22"
      min = "22"
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

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }
}

# define instance
resource "oci_core_instance" "free_instance0" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "freeInstance0"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "freeinstance0"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_app_catalog_subscriptions.oracle-linux_subscriptions.app_catalog_subscriptions[0], "listing_resource_id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf clean all",
      "sudo dnf upgrade -y",
      "sudo reboot"
    ]
  }
}

# get vnic IP and display the right ssh to this new instance
data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  instance_id         = oci_core_instance.free_instance0.id
}
data "oci_core_vnic" "app_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0], "vnic_id")
}
output "app" {
  value = "ssh opc@${data.oci_core_vnic.app_vnic.public_ip_address}"
}
