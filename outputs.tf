output "app_i0" {
  value = "ssh opc@${oci_core_instance.free_instance0.public_ip}"
}

output "app_wordpress" {
  value = "ssh ubuntu@${oci_core_instance.wordpress.public_ip}"
}