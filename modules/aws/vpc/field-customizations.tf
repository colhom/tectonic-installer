variable "tectonic_s3_bucket" {
  description = "name of tectonic s3 bucket"
  type        = "string"
}

variable "s3_ign_configs" {
  description = "map of ignition configs (name : content) pairs to host as s3 objects in the tectonic bucket"
  type        = "map"
}

resource "aws_s3_bucket_object" "ign_config" {
  bucket                 = "${var.tectonic_s3_bucket}"
  key                    = "${format("ign/%s.json",element(keys(var.s3_ign_configs),count.index))}"
  content                = "${element(values(var.s3_ign_configs),count.index)}"
  content_type           = "application/json"
  acl                    = "private"
  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_custom_cacert_${count.index}",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"

  count = "${length(keys(var.s3_ign_configs))}"
}

output "ign_config_s3_urls" {
  value = "${zipmap(keys(var.s3_ign_configs),formatlist("s3://%s/%s",var.tectonic_s3_bucket,aws_s3_bucket_object.ign_config.*.key))}"
}
