variable "sg_worker_id" {
  description = "id of worker security group"
  type        = "string"
}

variable "sg_master_id" {
  description = "id of master security group"
  type        = "string"
}

variable "enabled" {
  description = "enable this module"
}

variable "calico_metrics_port" {
  default = "9091"
}

variable "cluster_cidr" {
  type        = "string"
  description = "pod cidr of tectonic cluster"
}

variable "ipip_mode" {
  type        = "string"
  description = "calico ipip mode: one of [off, cross-subnet, always]"
}

variable "subnet_ids" {
  type        = "list"
  description = "all kubernetes subnet ids. used to apply custom ACL rule"
}

variable "vpc_id" {
  type        = "string"
  description = "id of target vpc"
}
