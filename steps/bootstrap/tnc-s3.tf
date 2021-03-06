# TNC
resource "aws_route53_zone" "tectonic_int" {
  vpc_id        = "${module.vpc.vpc_id}"
  name          = "${var.tectonic_base_domain}"
  force_destroy = true

  tags = "${merge(map(
      "Name", "${var.tectonic_cluster_name}_tectonic_int",
      "KubernetesCluster", "${var.tectonic_cluster_name}",
      "tectonicClusterID", "${var.tectonic_cluster_id}"
    ), var.tectonic_aws_extra_tags)}"
}

resource "aws_route53_record" "tectonic_tnc" {
  zone_id = "${aws_route53_zone.tectonic_int.id}"
  name    = "${var.tectonic_cluster_name}-tnc.${var.tectonic_base_domain}"
  type    = "CNAME"
  ttl     = "1"

  records = ["${aws_s3_bucket.tectonic.bucket_domain_name}"]
}
