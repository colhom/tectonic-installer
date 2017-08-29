variable "bootkube_id" {
  type = "string"
}

variable "calico_image" {
  description = "Container image for calico node"
  type        = "string"
}

variable "calico_cni_image" {
  description = "Container image for calico cni"
  type        = "string"
}

variable "reflector_agent_image" {
  description = "Container image for reflector agent"
  type        = "string"
}

variable "cluster_cidr" {
  description = "A CIDR notation IP range from which to assign pod IPs"
  type        = "string"
}

variable "enabled" {
  description = "If set true, calico network policy will be deployed"
}

variable "cni_version" {
  default = "0.3.0"
}

variable "log_level" {
  default = "DEBUG"
}

variable "calico_mtu" {
  type = "string"

  description = <<EOF
mtu for calico veth and ip tunnel interfaces- varies by platform and network configuration. 1480 is a safe for all suppored platforms"

For more information on how to calculate this number: https://docs.projectcalico.org/v2.5/usage/configuration/mtu
EOF
}

variable "calico_metrics_port" {
  default     = "9091"
  description = "port on which prometheus metrics handler for calico node will listen"
}

variable "calico_ipip_mode" {
  type = "string"

  description = <<EOF
one of [always, cross-subnet, off]: corresponds to CALICO_IPV4POOL_IPIP flag.
https://github.com/projectcalico/calico/blob/master/v2.5/reference/node/configuration.md
EOF
}

variable kube_apiserver_url {
  type = "string"
}
