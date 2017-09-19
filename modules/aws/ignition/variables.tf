variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "assets_s3_location" {
  type        = "string"
  description = "Location on S3 of the Bootkube/Tectonic assets to use (bucket/key)"
}

variable "kubeconfig_s3_location" {
  type        = "string"
  description = "Location on S3 of the kubeconfig file to use (bucket/key)"
}

variable "kube_dns_service_ip" {
  type        = "string"
  description = "Service IP used to reach kube-dns"
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
}

variable "kubelet_node_taints" {
  type        = "string"
  description = "Taints that Kubelet will apply on the node"
}

variable "kubelet_cni_bin_dir" {
  type = "string"
}

variable "bootkube_service" {
  type        = "string"
  description = "The content of the bootkube systemd service unit"
}

variable "tectonic_service" {
  type        = "string"
  description = "The content of the tectonic installer systemd service unit"
}

variable "tectonic_service_disabled" {
  description = "Specifies whether the tectonic installer systemd unit will be disabled. If true, no tectonic assets will be deployed"
  default     = false
}

variable "bootkube_service_disabled" {
  description = "Specifies whether the bootkube systemd unit will be disabled."
  default     = false
}

variable "cluster_name" {
  type = "string"
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type = "string"
}

variable "cni_network_provider" {
  description = <<EOF
Name of the cni network provider
EOF

  type = "string"
}

variable "calico_ipip_mode" {
  type = "string"

  description = <<EOF

one of [always, cross-subnet, off]: corresponds to CALICO_IPV4POOL_IPIP flag.

https://docs.projectcalico.org/v2.5/usage/configuration/ip-in-ip
EOF
}
