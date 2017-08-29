data "template_file" "disable-src-dst-check" {
  template = "${file("${path.module}/resources/disable-src-dst-check.sh")}"

  vars {
    awscli_image = "${var.awscli_image}"
  }
}

data "ignition_file" "disable-src-dst-check" {
  filesystem = "root"
  path       = "/opt/tectonic/disable-src-dst-check.sh"
  mode       = 0755

  content {
    content = "${data.template_file.disable-src-dst-check.rendered}"
  }
}

data "ignition_systemd_unit" "disable-src-dst-check" {
  name    = "disable-src-dst-check.service"
  enable  = "${var.enabled}"
  content = "${file("${path.module}/resources/services/disable-src-dst-check.service")}"
}
