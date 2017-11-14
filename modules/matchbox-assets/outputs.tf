output "id" {
  value = "${sha1(null_resource.matchbox-assets-tarball.id)}"
}

output "matchbox_assets_tarball_path" {
  description = "tarball containing /var/lib/matchbox/assets folder for this cluster"
  value       = "${local.tarball_path}"
}

output "registry_cache_aci_path" {
  description = "aci file for tectonic registry cache (runs as rkt pod)"
  value       = "${local.registry_cache_aci_path}"
}

output "terraform_tfvars_snippet" {
  value = <<EOD

// Put these variable definitions in your terraform.tfvars files for this cluster

// Use following registry cache configuration ONLY if you plan to serve the registry cache ACI via Matchbox HTTP server via HTTP
// In some advanced network configuration scenarios, matchbox HTTP interface may only be available during PXE installation phases, which
// necessitates hosting it on a different file server which the Tectonic nodes can access via the controller/worker networks post-install

tectonic_registry_cache_image_repo = "${replace(var.tectonic_metal_matchbox_http_url,"http://","")}/assets/${basename(local.registry_cache_aci_path)}"
tectonic_registry_cache_rkt_protocol = "http://"
tectonic_registry_cache_rkt_insecure_options = "image,http"

// If you ARE NOT using the matchbox HTTP server to server the ACI, make sure to
//  * upload ${local.registry_cache_aci_path} to your file server
//  * update registry cache configuration
//     (generic HTTPS example)
//     tectonic_registry_cache_image_repo = some-file-server.internal.my-company.com/path/to/tectonic-registry-cache.aci
//     tectonic_registry_cache_rkt_protocol = "https://
//     tectonic_registry_cache_rkt_insecure_options = "image"
//     tectonic_custom_cacertificates = ["/local_path/to/my/corporate/ca.crt"]

// The following should not be changed under any circumstance
tectonic_rkt_image_protocol = "docker://"
tectonic_rkt_insecure_options = "image,http"

tectonic_container_images = {
    calico                       = "localhost:5000/calico/node:v2.6.1"
    etcd_operator                = "localhost:5000/coreos/etcd-operator:v0.5.0"
    calico_cni                   = "localhost:5000/calico/cni:v1.11.0"
    kubedns_sidecar              = "localhost:5000/google_containers/k8s-dns-sidecar-amd64:1.14.5"
    pod_checkpointer             = "localhost:5000/coreos/pod-checkpointer:3517908b1a1837e78cfd041a0e51e61c7835d85f"
    stats_extender               = "localhost:5000/coreos/tectonic-stats-extender:487b3da4e175da96dabfb44fba65cdb8b823db2e"
    kubedns                      = "localhost:5000/google_containers/k8s-dns-kube-dns-amd64:1.14.5"
    stats_emitter                = "localhost:5000/coreos/tectonic-stats:6e882361357fe4b773adbf279cddf48cb50164c1"
    tectonic_etcd_operator       = "localhost:5000/coreos/tectonic-etcd-operator:v0.0.2"
    awscli                       = "localhost:5000/coreos/awscli:025a357f05242fdad6a81e8a6b520098aa65a600"
    console                      = "localhost:5000/coreos/tectonic-console:v2.3.4"
    error_server                 = "localhost:5000/coreos/tectonic-error-server:1.0"
    flannel                      = "localhost:5000/coreos/flannel:v0.8.0-amd64"
    identity                     = "localhost:5000/coreos/dex:v2.7.1"
    node_agent                   = "localhost:5000/coreos/node-agent:v1.7.5-kvo.3"
    flannel_cni                  = "localhost:5000/coreos/flannel-cni:v0.2.0"
    ingress_controller           = "localhost:5000/google_containers/nginx-ingress-controller:0.9.0-beta.15"
    pod_infra_image              = "localhost:5000/google_containers/pause-amd64:3.0"
    tectonic_channel_operator    = "localhost:5000/coreos/tectonic-channel-operator:0.5.4"
    tectonic_torcx               = "localhost:5000/coreos/tectonic-torcx:installer-latest"
    bootkube                     = "localhost:5000/coreos/bootkube:v0.6.2"
    etcd                         = "localhost:5000/coreos/etcd:v3.1.8"
    heapster                     = "localhost:5000/google_containers/heapster:v1.4.1"
    kenc                         = "localhost:5000/coreos/kenc:0.0.2"
    tectonic_cluo_operator       = "localhost:5000/coreos/tectonic-cluo-operator:v0.2.3"
    addon_resizer                = "localhost:5000/google_containers/addon-resizer:2.1"
    hyperkube                    = "localhost:5000/coreos/hyperkube:v1.7.9_coreos.0"
    kubednsmasq                  = "localhost:5000/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5"
    kube_version                 = "localhost:5000/coreos/kube-version:0.1.0"
    kube_version_operator        = "localhost:5000/coreos/kube-version-operator:v1.7.9-kvo.5"
    tectonic_prometheus_operator = "localhost:5000/coreos/tectonic-prometheus-operator:v1.7.1"
}

tectonic_container_base_images = {
    tectonic_monitoring_auth = "localhost:5000/coreos/tectonic-monitoring-auth"
    config_reload            = "localhost:5000/coreos/configmap-reload"
    addon_resizer            = "localhost:5000/coreos/addon-resizer"
    kube_state_metrics       = "localhost:5000/coreos/kube-state-metrics"
    grafana                  = "localhost:5000/coreos/monitoring-grafana"
    grafana_watcher          = "localhost:5000/coreos/grafana-watcher"
    prometheus_operator      = "localhost:5000/coreos/prometheus-operator"
    prometheus_config_reload = "localhost:5000/coreos/prometheus-config-reloader"
    prometheus               = "localhost:5000/prometheus/prometheus"
    alertmanager             = "localhost:5000/prometheus/alertmanager"
    node_exporter            = "localhost:5000/prometheus/node-exporter"
}
EOD
}
