output "version" {
  value = "${var.cl_version == "latest" ? data.external.version.result["version"] : var.cl_version}"
}
