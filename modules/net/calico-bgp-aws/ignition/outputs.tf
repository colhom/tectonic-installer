output "ignition_file_id" {
  value = "${data.ignition_file.disable-src-dst-check.id}"
}

output "ignition_systemd_unit_id" {
  value = "${data.ignition_systemd_unit.disable-src-dst-check.id}"
}

output "name" {
  value = "calico-bgp-aws-ignition"
}
