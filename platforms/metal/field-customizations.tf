locals {
  // more boilerplate that could be remedied via data url support in append/replace blocks
  fc_ign_url_tmpl = "%s/ignition?role=%s&module=%s"
}

// hack until ignition supports appending/replacing configs with data: urls
// then we don't need to stamp out matchbox profiles/groups in order
// to append configs in this scenario.

// registry cache boilerplate
resource "matchbox_profile" "worker-registry-cache" {
  name         = "tecworker-registry-cache"
  raw_ignition = "${module.ignition_workers.registry_cache_ign_config}"
}

resource "matchbox_profile" "master-registry-cache" {
  name         = "tecmaster-registry-cache"
  raw_ignition = "${module.ignition_masters.registry_cache_ign_config}"
}

resource "matchbox_group" "worker-registry-cache" {
  name    = "tecworker-registry-cache"
  profile = "${matchbox_profile.worker-registry-cache.name}"

  selector {
    role   = "worker"
    module = "registry-cache"
  }

  metadata {}
}

resource "matchbox_group" "master-registry-cache" {
  name    = "tecmaster-registry-cache"
  profile = "${matchbox_profile.master-registry-cache.name}"

  selector {
    role   = "master"
    module = "registry-cache"
  }

  metadata {}
}

// custom cacertificates boilerplate
resource "matchbox_profile" "worker-custom-cacerts" {
  name         = "tecworker-custom-cacerts"
  raw_ignition = "${module.ignition_workers.custom_cacerts_ign_config}"
}

resource "matchbox_profile" "master-custom-cacerts" {
  name         = "tecmaster-custom-cacerts"
  raw_ignition = "${module.ignition_masters.custom_cacerts_ign_config}"
}

resource "matchbox_group" "worker-custom-cacerts" {
  name    = "tecworker-custom-cacerts"
  profile = "${matchbox_profile.worker-custom-cacerts.name}"

  selector {
    role   = "worker"
    module = "custom-cacerts"
  }

  metadata {}
}

resource "matchbox_group" "master-custom-cacerts" {
  name    = "tecmaster-custom-cacerts"
  profile = "${matchbox_profile.master-custom-cacerts.name}"

  selector {
    role   = "master"
    module = "custom-cacerts"
  }

  metadata {}
}
