variable "registry_cache_aci_url" {
  default     = "https://s3-us-west-2.amazonaws.com/tectonic-offline/coreos-tectonic-registry-cache-1.7.9-tectonic.1-offline.aci"
  description = "where terraform should download offline registry cache ACI from in order to populate matchbox assets for offline install"
}
