data "aws_availability_zones" "azs" {}

resource "aws_vpc" "new_vpc" {
  count                = "${var.external_vpc_id == "" ? 1 : 0}"
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
      "Name", "${var.cluster_name}-vpc",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"
}

data "aws_vpc" "cluster_vpc" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  id = "${var.external_vpc_id == "" ? join(" ", aws_vpc.new_vpc.*.id) : var.external_vpc_id }"
}

module "calico-bgp-aws-vpc" {
  source       = "../../net/calico-bgp-aws/vpc"
  vpc_id       = "${var.external_vpc_id == "" ? aws_vpc.new_vpc.id : var.external_vpc_id}"
  subnet_ids   = "${compact(distinct(concat(aws_subnet.master_subnet.*.id, aws_subnet.worker_subnet.*.id, data.aws_subnet.external_master.*.id, data.aws_subnet.external_worker.*.id)))}"
  sg_worker_id = "${aws_security_group.worker.id}"
  sg_master_id = "${aws_security_group.master.id}"
  enabled      = "${var.cni_network_provider == "calico-bgp" ? true : false}"
  ipip_mode    = "${var.calico_ipip_mode}"
  cluster_cidr = "${var.cluster_cidr}"
}
