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
