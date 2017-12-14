module "container_linux" {
  source = "../../modules/container_linux"

  channel    = "${var.tectonic_container_linux_channel}"
  cl_version = "${var.tectonic_container_linux_version}"
}

// Install CoreOS to disk
resource "matchbox_group" "coreos_install" {
  count   = "${length(var.tectonic_metal_controller_names) + length(var.tectonic_metal_worker_names)}"
  name    = "${format("coreos-install-%s", element(concat(var.tectonic_metal_controller_names, var.tectonic_metal_worker_names), count.index))}"
  profile = "${matchbox_profile.coreos_install.name}"

  selector {
    mac = "${element(concat(var.tectonic_metal_controller_macs, var.tectonic_metal_worker_macs), count.index)}"
  }

  metadata {
    coreos_channel     = "${var.tectonic_container_linux_channel}"
    coreos_version     = "${module.container_linux.version}"
    ignition_endpoint  = "${var.tectonic_metal_matchbox_http_url}/ignition"
    baseurl            = "${var.tectonic_metal_matchbox_http_url}/assets/coreos"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"
  }
}

// DO NOT PLACE SECRETS IN USER-DATA

module "ignition_masters" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl      = "${var.tectonic_bootstrap_upgrade_cl}"
  cluster_name              = "${var.tectonic_cluster_name}"
  container_images          = "${var.tectonic_container_images}"
  etcd_advertise_name_list  = "${var.tectonic_metal_controller_domains}"
  etcd_count                = "${length(var.tectonic_metal_controller_names)}"
  etcd_initial_cluster_list = "${var.tectonic_metal_controller_domains}"
  image_re                  = "${var.tectonic_image_re}"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  kubelet_cni_bin_dir       = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  use_metadata              = false
  tectonic_vanilla_k8s      = "${var.tectonic_vanilla_k8s}"

  registry_cache_image_repo           = "${var.tectonic_registry_cache_image_repo}"
  registry_cache_image_tag            = "${var.tectonic_registry_cache_image_tag}"
  registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"
  registry_cache_rkt_image_protocol   = "${var.tectonic_registry_cache_rkt_protocol}"
  rkt_image_protocol                  = "${var.tectonic_rkt_image_protocol}"
  rkt_insecure_options                = "${var.tectonic_rkt_insecure_options}"
  custom_cacertificates               = "${var.tectonic_custom_cacertificates}"
}

resource "matchbox_group" "controller" {
  count   = "${length(var.tectonic_metal_controller_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_controller_names, count.index))}"
  profile = "${matchbox_profile.tectonic_controller.name}"

  selector {
    mac = "${element(var.tectonic_metal_controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_controller_domains, count.index)}"
    etcd_enabled       = "${var.tectonic_experimental ? "false" : length(compact(var.tectonic_etcd_servers)) != 0 ? "false" : "true"}"
    exclude_tectonic   = "${var.tectonic_vanilla_k8s}"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"

    ign_bootkube_path_unit_json         = "${jsonencode(module.bootkube.systemd_path_unit_rendered)}"
    ign_bootkube_service_json           = "${jsonencode(module.bootkube.systemd_service_rendered)}"
    ign_docker_dropin_json              = "${jsonencode(module.ignition_masters.docker_dropin_rendered)}"
    ign_etcd_dropin_json                = "${jsonencode(module.ignition_masters.etcd_dropin_rendered_list[count.index])}"
    ign_installer_kubelet_env_json      = "${jsonencode(module.ignition_masters.installer_kubelet_env_rendered)}"
    ign_k8s_node_bootstrap_service_json = "${jsonencode(module.ignition_masters.k8s_node_bootstrap_service_rendered)}"
    ign_kubelet_service_json            = "${jsonencode(module.ignition_masters.kubelet_service_rendered)}"
    ign_max_user_watches_json           = "${jsonencode(module.ignition_masters.max_user_watches_rendered)}"
    ign_tectonic_path_unit_json         = "${jsonencode(module.tectonic.systemd_path_unit_rendered)}"
    ign_tectonic_service_json           = "${jsonencode(module.tectonic.systemd_service_rendered)}"

    //field custom
    registry_cache_ign_master_config_url  = "${format(local.fc_ign_url_tmpl,var.tectonic_metal_matchbox_http_url,"master","registry-cache")}"
    registry_cache_ign_master_config_hash = "${sha512(matchbox_profile.master-registry-cache.raw_ignition)}"

    custom_cacerts_ign_master_config_url  = "${format(local.fc_ign_url_tmpl,var.tectonic_metal_matchbox_http_url,"master","custom-cacerts")}"
    custom_cacerts_ign_master_config_hash = "${sha512(matchbox_profile.master-custom-cacerts.raw_ignition)}"

    # static IP
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_mac_address     = "${element(var.tectonic_metal_controller_macs, count.index)}"
    coreos_network_adapter = "${var.tectonic_metal_master_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_master_ip, count.index,"")}"
    coreos_network_gateway = "${var.tectonic_metal_master_gateway}"
  }
}

module "ignition_workers" {
  source = "../../modules/ignition"

  bootstrap_upgrade_cl = "${var.tectonic_bootstrap_upgrade_cl}"
  container_images     = "${var.tectonic_container_images}"
  image_re             = "${var.tectonic_image_re}"
  kube_dns_service_ip  = "${module.bootkube.kube_dns_service_ip}"
  kubelet_cni_bin_dir  = "${var.tectonic_networking == "calico" || var.tectonic_networking == "canal" ? "/var/lib/cni/bin" : "" }"
  kubelet_node_label   = "node-role.kubernetes.io/node"
  kubelet_node_taints  = ""
  tectonic_vanilla_k8s = "${var.tectonic_vanilla_k8s}"

  registry_cache_image_repo           = "${var.tectonic_registry_cache_image_repo}"
  registry_cache_image_tag            = "${var.tectonic_registry_cache_image_tag}"
  registry_cache_rkt_insecure_options = "${var.tectonic_registry_cache_rkt_insecure_options}"
  registry_cache_rkt_image_protocol   = "${var.tectonic_registry_cache_rkt_protocol}"
  rkt_image_protocol                  = "${var.tectonic_rkt_image_protocol}"
  rkt_insecure_options                = "${var.tectonic_rkt_insecure_options}"
  custom_cacertificates               = "${var.tectonic_custom_cacertificates}"
}

resource "matchbox_group" "worker" {
  count   = "${length(var.tectonic_metal_worker_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_worker_names, count.index))}"
  profile = "${matchbox_profile.tectonic_worker.name}"

  selector {
    mac = "${element(var.tectonic_metal_worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_worker_domains, count.index)}"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"

    # extra data
    kubelet_image_url  = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
    kubelet_image_tag  = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"
    kube_version_image = "${var.tectonic_container_images["kube_version"]}"

    ign_docker_dropin_json              = "${jsonencode(module.ignition_workers.docker_dropin_rendered)}"
    ign_installer_kubelet_env_json      = "${jsonencode(module.ignition_workers.installer_kubelet_env_rendered)}"
    ign_k8s_node_bootstrap_service_json = "${jsonencode(module.ignition_workers.k8s_node_bootstrap_service_rendered)}"
    ign_kubelet_service_json            = "${jsonencode(module.ignition_workers.kubelet_service_rendered)}"
    ign_max_user_watches_json           = "${jsonencode(module.ignition_workers.max_user_watches_rendered)}"

    //field custom
    registry_cache_ign_worker_config_url  = "${format(local.fc_ign_url_tmpl,var.tectonic_metal_matchbox_http_url,"worker","registry-cache")}"
    registry_cache_ign_worker_config_hash = "${sha512(matchbox_profile.worker-registry-cache.raw_ignition)}"

    custom_cacerts_ign_worker_config_url  = "${format(local.fc_ign_url_tmpl,var.tectonic_metal_matchbox_http_url,"worker","custom-cacerts")}"
    custom_cacerts_ign_worker_config_hash = "${sha512(matchbox_profile.worker-custom-cacerts.raw_ignition)}"

    # static IP
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_mac_address     = "${element(var.tectonic_metal_worker_macs, count.index)}"
    coreos_network_adapter = "${var.tectonic_metal_worker_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_worker_ip, count.index,"")}"
    coreos_network_gateway = "${var.tectonic_metal_worker_gateway}"
  }
}
