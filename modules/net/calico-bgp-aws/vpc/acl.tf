resource "aws_network_acl" "pod_network_isolation" {
  count      = "${var.enabled && var.ipip_mode == "cross-subnet" ? 1 : 0}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "pod-network-isolation"
  }
}

resource "aws_network_acl_rule" "pod_network_ingress_deny" {
  count          = "${var.enabled && var.ipip_mode == "cross-subnet" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.pod_network_isolation.id}"
  egress         = false

  protocol    = "-1"
  rule_number = 50
  rule_action = "deny"
  cidr_block  = "${var.cluster_cidr}"
  from_port   = 0
  to_port     = 0
}

resource "aws_network_acl_rule" "pod_network_egress_deny" {
  count          = "${var.enabled && var.ipip_mode == "cross-subnet" ? 1 : 0}"
  network_acl_id = "${aws_network_acl.pod_network_isolation.id}"
  egress         = true

  protocol    = "-1"
  rule_number = 50
  rule_action = "deny"
  cidr_block  = "${var.cluster_cidr}"
  from_port   = 0
  to_port     = 0
}
