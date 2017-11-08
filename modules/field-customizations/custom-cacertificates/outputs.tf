output "id" {
  value = "${sha1(data.ignition_config.main.rendered)}"
}

output "ignition_config_content" {
  value = "${data.ignition_config.main.rendered}"
}

output "ignition_config_data_url" {
  value = "${format("data:application/json;base64,%s", base64encode(data.ignition_config.main.rendered))}"
}
