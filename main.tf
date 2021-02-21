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
}

resource "oci_core_instance" "wordpress" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "wordpress"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "wordpress"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu-20-04-minimal.images.0.id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}