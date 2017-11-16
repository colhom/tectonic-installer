variable "registry_cache_aci_url" {
  default     = "https://s3-us-west-2.amazonaws.com/tectonic-offline/coreos-tectonic-registry-cache-1.7.9-tectonic.1-offline.aci"
  description = "Where terraform should download offline registry cache ACI from in order to populate matchbox assets for offline install"
}

variable "container_linux_download_base_url" {
  default = ""

  description = <<EOD
URL prefix for downloading container linux asset files. Leave blank to use CoreOS public release mirrors to fetch assets for your channel and version.

If you are hosting your own container linux assets, read through the get-coreos script in this module to inventory which asset files and GPG public keys you'll need
to import into your environment. Then provide the URL prefix for those files via this tfvar before applying the module and generating the asset tarball.
EOD
}
