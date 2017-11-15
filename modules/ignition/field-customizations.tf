module "tectonic-registry-cache" {
  source = "../../modules/field-customizations/tectonic-registry-cache"

  image_repo           = "${var.registry_cache_image_repo}"
  image_tag            = "${var.registry_cache_image_tag}"
  rkt_image_protocol   = "${var.registry_cache_rkt_image_protocol}"
  rkt_insecure_options = "${var.registry_cache_rkt_insecure_options}"
}

module "custom-cacertificates" {
  source         = "../../modules/field-customizations/custom-cacertificates"
  cacertificates = "${var.custom_cacertificates}"
}

output "registry_cache_ign_config" {
  value = "${module.tectonic-registry-cache.ignition_config_content}"
}

output "custom_cacerts_ign_config" {
  value = "${module.custom-cacertificates.ignition_config_content}"
}
