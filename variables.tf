# OCI
variable "compartment_ocid" {}
variable "fingerprint" {}
variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
variable "os_major_version" {
  default = 8
}
variable "private_key_path" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "home_wan_subnet" {}
variable "ssh_private_key" {}