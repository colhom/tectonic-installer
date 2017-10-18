locals {
  fs_type = "ext4"

  devfmt  = "/dev/xvdc%s"
  letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
  devs    = "${formatlist(local.devfmt,local.letters)}"
  labels  = "${formatlist("ephemeral-%s",local.letters)}"

  // http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#instance-store-volumes
  known_edisk_counts = {
    "m3.medium"  = 1
    "m3.large"   = 1
    "m3.xlarge"  = 2
    "m3.2xlarge" = 2

    "c3.large"   = 2
    "c3.xlarge"  = 2
    "c3.2xlarge" = 2
    "c3.4xlarge" = 2
    "c3.8xlarge" = 2
  }

  edisk_cnt = "${lookup(local.known_edisk_counts,var.ec2_type,0)}"
  edisks    = "${slice(local.devs,0,local.edisk_cnt)}"
}

data "ignition_disk" "ephemeral" {
  count      = "${length(local.edisks)}"
  device     = "${local.edisks[count.index]}"
  wipe_table = true

  partition {
    start = 2048
    label = "${local.labels[count.index]}"
  }
}

data "ignition_filesystem" "ephemeral" {
  count = "${length(local.edisks)}"
  name  = "ephemeral${count.index}"

  mount {
    device = "${local.edisks[count.index]}"
    format = "${local.fs_type}"
    create = true
  }
}

data "ignition_systemd_unit" "ephemeral_mount" {
  count  = "${length(local.edisks)}"
  name   = "mnt-disks-ephemeral${count.index}.mount"
  enable = true

  content = <<EOF
[Mount]
What="${local.edisks[count.index]}"
Where="/mnt/disks/ephemeral${count.index}"
[Install]
WantedBy=local-fs.target
EOF
}
