variable "enabled" {
  description = "If set true, calico bgp aws-specific services will be enabled"
}

variable "awscli_image" {
  description = "image containing aws cli tool"
  type        = "string"
}

variable "ipip_mode" {
  type        = "string"
  description = "calico ipip mode: one of [off, cross-subnet, always]"
}
