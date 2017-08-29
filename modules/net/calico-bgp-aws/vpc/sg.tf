# master
resource "aws_security_group_rule" "master_ingress_bgp" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_master_id}"
  protocol          = "tcp"
  from_port         = 179
  to_port           = 179
  self              = true
}

resource "aws_security_group_rule" "master_ingress_bgp_from_worker" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_master_id}"
  source_security_group_id = "${var.sg_worker_id}"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
}

resource "aws_security_group_rule" "master_ingress_bgp_metrics" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_master_id}"
  protocol          = "tcp"
  from_port         = "${var.calico_metrics_port}"
  to_port           = "${var.calico_metrics_port}"
  self              = true
}

resource "aws_security_group_rule" "master_ingress_bgp_metrics_from_worker" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_master_id}"
  source_security_group_id = "${var.sg_worker_id}"
  protocol                 = "tcp"
  from_port                = "${var.calico_metrics_port}"
  to_port                  = "${var.calico_metrics_port}"
}

resource "aws_security_group_rule" "master_ingress_ipip" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_master_id}"
  protocol          = 94
  from_port         = 0
  to_port           = 0
  self              = true
}

resource "aws_security_group_rule" "master_ingress_ipip_from_worker" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_master_id}"
  source_security_group_id = "${var.sg_worker_id}"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
}

resource "aws_security_group_rule" "master_ingress_ipv4encap" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_master_id}"
  protocol          = 4
  from_port         = 0
  to_port           = 0
  self              = true
}

resource "aws_security_group_rule" "master_ingress_ipv4encap_from_worker" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_master_id}"
  source_security_group_id = "${var.sg_worker_id}"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
}

## worker

resource "aws_security_group_rule" "worker_ingress_bgp" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_worker_id}"
  protocol          = "tcp"
  from_port         = 179
  to_port           = 179
  self              = true
}

resource "aws_security_group_rule" "worker_ingress_bgp_from_master" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_worker_id}"
  source_security_group_id = "${var.sg_master_id}"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
}

resource "aws_security_group_rule" "worker_ingress_ipip" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_worker_id}"
  protocol          = 94
  from_port         = 0
  to_port           = 0
  self              = true
}

resource "aws_security_group_rule" "worker_ingress_ipip_from_master" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_worker_id}"
  source_security_group_id = "${var.sg_master_id}"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
}

resource "aws_security_group_rule" "worker_ingress_ipv4encap" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_worker_id}"
  protocol          = 4
  from_port         = 0
  to_port           = 0
  self              = true
}

resource "aws_security_group_rule" "worker_ingress_ipv4encap_from_master" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_worker_id}"
  source_security_group_id = "${var.sg_master_id}"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
}

resource "aws_security_group_rule" "worker_ingress_bgp_metrics" {
  count             = "${var.enabled ? 1 : 0}"
  type              = "ingress"
  security_group_id = "${var.sg_worker_id}"
  protocol          = "tcp"
  from_port         = "${var.calico_metrics_port}"
  to_port           = "${var.calico_metrics_port}"
  self              = true
}

resource "aws_security_group_rule" "worker_ingress_bgp_metrics_from_master" {
  count                    = "${var.enabled ? 1 : 0}"
  type                     = "ingress"
  security_group_id        = "${var.sg_worker_id}"
  source_security_group_id = "${var.sg_master_id}"
  protocol                 = "tcp"
  from_port                = "${var.calico_metrics_port}"
  to_port                  = "${var.calico_metrics_port}"
}
