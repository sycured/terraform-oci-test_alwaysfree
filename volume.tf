resource "oci_core_volume" "vol1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  size_in_gbs         = 50
}

resource "oci_core_volume_attachment" "vol1" {
  attachment_type = "paravirtualized"
  instance_id     = data.oci_core_instance.free_instance0.id
  volume_id       = data.oci_core_volume.vol1.id
}