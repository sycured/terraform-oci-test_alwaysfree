data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_instance" "free_instance0" {
  instance_id = oci_core_instance.free_instance0.id
}

data "oci_core_volume" "vol1" {
  volume_id = oci_core_volume.vol1.id
}

data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  instance_id         = data.oci_core_instance.free_instance0.id
}

data "oci_core_vnic" "app_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0], "vnic_id")
}