data "template_file" "calico-bgp" {
  template = "${file("${path.module}/resources/manifests/kube-calico-bgp.yaml")}"

  vars {
    kube_apiserver_url    = "${var.kube_apiserver_url}"
    cni_version           = "${var.cni_version}"
    log_level             = "${var.log_level}"
    calico_image          = "${var.calico_image}"
    calico_cni_image      = "${var.calico_cni_image}"
    reflector_agent_image = "${var.reflector_agent_image}"
    cluster_cidr          = "${var.cluster_cidr}"
    bootkube_id           = "${var.bootkube_id}"
    host_cni_bin          = "/var/lib/cni/bin"
    calico_mtu            = "${var.calico_mtu}"
    calico_metrics_port   = "${var.calico_metrics_port}"
    calico_ipip_mode      = "${var.calico_ipip_mode}"
  }
}

resource "local_file" "calico-bgp" {
  count = "${ var.enabled ? 1 : 0 }"

  content  = "${data.template_file.calico-bgp.rendered}"
  filename = "./generated/manifests/kube-calico-bgp.yaml"
}

data "template_file" "calico-bird-templates" {
  template = "${file("${path.module}/resources/manifests/calico-bird-templates.yaml")}"

  vars {
    bootkube_id = "${var.bootkube_id}"
  }
}

resource "local_file" "calico-bird-templates" {
  count    = "${ var.enabled ? 1 : 0 }"
  content  = "${data.template_file.calico-bird-templates.rendered}"
  filename = "./generated/manifests/calico-bird-templates.yaml"
}
