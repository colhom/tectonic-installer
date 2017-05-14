// Install CoreOS to disk
resource "matchbox_group" "coreos-install" {
  count   = "${length(var.tectonic_metal_controller_names) + length(var.tectonic_metal_worker_names)}"
  name    = "${format("coreos-install-%s", element(concat(var.tectonic_metal_controller_names, var.tectonic_metal_worker_names), count.index))}"
  profile = "${matchbox_profile.coreos-install.name}"

  selector {
    mac = "${element(concat(var.tectonic_metal_controller_macs, var.tectonic_metal_worker_macs), count.index)}"
  }

  metadata {
    coreos_channel     = "${var.tectonic_cl_channel}"
    coreos_version     = "${var.tectonic_metal_cl_version}"
    ignition_endpoint  = "${var.tectonic_metal_matchbox_http_url}/ignition"
    baseurl            = "${var.tectonic_metal_matchbox_http_url}/assets/coreos"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"
  }
}

// DO NOT PLACE SECRETS IN USER-DATA

resource "matchbox_group" "controller" {
  count   = "${length(var.tectonic_metal_controller_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_controller_names, count.index))}"
  profile = "${matchbox_profile.tectonic-controller.name}"

  selector {
    mac = "${element(var.tectonic_metal_controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.tectonic_metal_controller_domains, count.index)}"
    etcd_enabled         = "${var.tectonic_experimental ? "false" : "true"}"
    etcd_name            = "${element(var.tectonic_metal_controller_names, count.index)}"
    etcd_initial_cluster = "${join(",", formatlist("%s=http://%s:2380", var.tectonic_metal_controller_names, var.tectonic_metal_controller_domains))}"
    k8s_dns_service_ip   = "${module.bootkube.kube_dns_service_ip}"
    ssh_authorized_key   = "${var.tectonic_ssh_authorized_key}"
    exclude_tectonic     = "${var.tectonic_vanilla_k8s}"

    # extra data
    etcd_image_url    = "${element(split(":", var.tectonic_container_images["etcd"]), 0)}"
    etcd_image_tag    = "v${var.tectonic_versions["etcd"]}"
    kubelet_image_url = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kubelet_image_tag = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"

    # custom pause container image
    pod_infra_image = "${var.container_images["pod_infra_image"]}"

    rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
    rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

    # static IP
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_network_adapter = "${var.tectonic_metal_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_master_ip, count.index,"")}"
    coreos_network_gateway = "${var.tectonic_metal_master_gateway}"

    # custom CA Cert
    coreos_custom_cacertificate = "${replace(var.tectonic_metal_customcacertificate,"\n","\\n")}"

    # custom pause container image
    pod_infra_image = "${var.tectonic_container_images["pod_infra_image"]}"
  }
}

resource "matchbox_group" "worker" {
  count   = "${length(var.tectonic_metal_worker_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_worker_names, count.index))}"
  profile = "${matchbox_profile.tectonic-worker.name}"

  selector {
    mac = "${element(var.tectonic_metal_worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_worker_domains, count.index)}"
    k8s_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"

    # extra data
    kubelet_image_url  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kubelet_image_tag  = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
    kube_version_image = "${var.tectonic_container_images["kube_version"]}"

    # custom pause container image
    pod_infra_image = "${var.container_images["pod_infra_image"]}"

    rkt_image_protocol   = "${var.tectonic_rkt_image_protocol}"
    rkt_insecure_options = "${var.tectonic_rkt_insecure_options}"

    # static IP
    coreos_static_ip       = "${var.tectonic_static_ip}"
    coreos_network_adapter = "${var.tectonic_metal_networkadapter}"
    coreos_network_dns     = "${var.tectonic_metal_dnsserver}"
    coreos_network_address = "${var.tectonic_static_ip == "" ? "" : lookup(var.tectonic_metal_worker_ip, count.index, "")}"
    coreos_network_gateway = "${var.tectonic_metal_worker_gateway}"

    # custom CA Cert
    coreos_custom_cacertificate = "${replace(var.tectonic_metal_customcacertificate,"\n","\\n")}"

    # custom pause container image
    pod_infra_image = "${var.tectonic_container_images["pod_infra_image"]}"
  }
}
