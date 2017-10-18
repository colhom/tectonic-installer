data "ignition_config" "main" {
  files = ["${list(
    var.ign_installer_kubelet_env_id,
    var.ign_max_user_watches_id,
    var.ign_s3_puller_id,
  )}"]

  disks       = ["${data.ignition_disk.ephemeral.*.id}"]
  filesystems = ["${data.ignition_filesystem.ephemeral.*.id}"]

  systemd = ["${concat(list(
     var.ign_docker_dropin_id, var.ign_k8s_node_bootstrap_service_id,
     var.ign_kubelet_service_id, var.ign_locksmithd_service_id,
    ),
    data.ignition_systemd_unit.ephemeral_mount.*.id,
  )}"]
}
