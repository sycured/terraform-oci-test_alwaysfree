output "app" {
  value = "ssh opc@${data.oci_core_vnic.app_vnic.public_ip_address}"
}