# calico-bgp module

## Custom BIRD templates

Tectonic will require customized BIRD templates, which are supplied to calico-node via a [configmap](resources/manifests/calico-bird-templates.yaml) mounted as a volume.

__When bumping the version of the calico-node container__, we should also make sure to update the BIRD template configmap as well.

## Building configmap/calico-bird-templates

```sh
git clone git@github.com:coreos/calico.git
cd calico/
git checkout v2.5.1-tectonic
cd calico_node/filesystem/etc/calico/confd
OUT_PATH=/path/to/tectonic-installer/modules/net/calico-bgp/resources/manifests/calico-bird-templates.yaml ./mk-calico-templates-configmap.sh

# Check modifications
cd /path/to/tectonic-installer/
git status
```
