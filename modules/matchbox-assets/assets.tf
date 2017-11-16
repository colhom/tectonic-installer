locals {
  base_dir                = "${format("%s/matchbox",path.cwd)}"
  matchbox_ca_path        = "${format("%s/matchbox-ca.crt",local.base_dir)}"
  assets_dir              = "${format("%s/assets",local.base_dir)}"
  registry_cache_aci_path = "${local.assets_dir}/tectonic-registry-cache-${lookup(var.tectonic_versions,"tectonic")}.aci"
  tarball_path            = "${local.base_dir}/matchbox-assets-${var.tectonic_cluster_name}.tgz"
}

resource "null_resource" "assets-directory-structure" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.assets_dir}"
  }
}

resource "null_resource" "container-linux" {
  depends_on = ["null_resource.assets-directory-structure"]

  provisioner "local-exec" {
    command = "${format("BASE_URL=\"%s\" %s/get-coreos %s %s %s",
                 var.container_linux_download_base_url,
                 path.module,
                 var.tectonic_container_linux_channel,
                 var.tectonic_container_linux_version,
                 local.assets_dir)}"
  }
}

resource "null_resource" "offline-registry-cache" {
  depends_on = ["null_resource.assets-directory-structure"]

  provisioner "local-exec" {
    command = "wget -nv ${var.registry_cache_aci_url} -O ${local.registry_cache_aci_path}"
  }
}

resource "null_resource" "matchbox-assets-tarball" {
  depends_on = ["null_resource.offline-registry-cache", "null_resource.container-linux"]

  provisioner "local-exec" {
    command = "tar -C ${local.base_dir} -czvf ${local.tarball_path} ${basename(local.assets_dir)}/"
  }
}
