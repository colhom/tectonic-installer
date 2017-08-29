output "id" {
  value = "${ var.enabled ? "${sha1("${join(" ", local_file.calico-bgp.*.id, local_file.calico-bird-templates.*.id)}")}" : "# calico-bgp disabled" }"
}

output "name" {
  value = "calico-bgp"
}
