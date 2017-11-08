locals {
  cert_dir   = "/etc/ssl/certs"
  cert_templ = "tectonic-custom-cacert-%d.pem"
}

data "ignition_config" "main" {
  files = ["${data.ignition_file.custom-cacert.*.id}"]

  systemd = ["${data.ignition_systemd_unit.update-ca-certificates-rehash.*.id}"]
}

data "ignition_file" "custom-cacert" {
  count = "${length(var.cacertificates)}"

  filesystem = "root"
  path       = "${format("%s/%s",local.cert_dir,format(local.cert_templ,count.index))}"
  mode       = 0640

  content {
    content = "${file(var.cacertificates[count.index])}"
  }
}

data "ignition_systemd_unit" "update-ca-certificates-rehash" {
  name   = "update-ca-certificates-rehash.service"
  enable = true
  count  = "${length(var.cacertificates) > 0 ? 1 : 0}"

  content = <<EOF
[Unit]
After=network-pre.target
Before=kubelet.service docker.service
Wants=network-pre.target

[Service]
ExecStart=/usr/sbin/update-ca-certificates
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
RequiredBy=kubelet.service docker.service

EOF
}
