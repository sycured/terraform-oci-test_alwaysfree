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
  compartment_id = var.compartment_ocid
  listing_id     = oci_core_app_catalog_subscription.oracle-linux_subscription.listing_id

  filter {
    name   = "listing_resource_version"
    values = ["${oci_core_app_catalog_subscription.oracle-linux_subscription.listing_resource_version}"]
  }
}