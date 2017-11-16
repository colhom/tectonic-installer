## Tectonic metal offline instructions

This installation procedure allows for Tectonic installation in an environment where matchbox, controllers and workers have no egress what-so-ever (no routes, DNS forwarding or proxies needed).

### Steps

### Step 0:

  * Clone this git repostory at the branch matching your desired version
  ```sh
  $> git clone -b 1.7.9_tectonic.1-offline https://github.com/coreos/tectonic-installer ./tectonic_1.7.9-tectonic.1-offline
  $> cd tectonic_1.7.9-tectonic.1-offline
  ```

  * Download Tectonic installer release tarball at **the exact version** matching this offline branch.

  * Extract pre-compiled release binaries directly from the release tarball into the offline installer git repo

  ```sh
  $> tar --strip-components=1 -zxvf ~/Downloads/tectonic_1.7.9-tectonic.1.tar.gz tectonic_1.7.9-tectonic.1/tectonic-installer/
  ```
  This will create the `tectonic-installer/` subdirectory, which contains pre-compiled release binaries needed for the terraform install process.

#### Step 1:

  Follow the [standard bare metal installation](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html) instructions for the version of Tectonic matching the offline release, skipping the Download/extract installer step.

  * Also skip the optional step of pre-populating Matchbox assets- that will be covered specifically in Step 2.

  * Make sure to set `tectonic_container_linux_version` to the latest numeric OS version for your CL channel. Do not leave the default of value "latest". [CL releases](https://coreos.com/releases/)

  * If you need additional CAs trusted on the CL system bundle, make sure `tectonic_custom_cacertificates` list tfvar is set properly. If you have image registr(ies) in your offline environment using TLS, ensure the appropriate CA(s) for those server certificates are listed.

  Pause the standard install flow after you've verified the `terraform plan` step works correctly, but **before** running the `terraform apply` step.

#### Step 2:

  At this juncture, we will pre-populate the Matchbox assets folder. (Or optionally, HTTP/HTTPS fileservers of your choice. More on that shortly)

  The machine hosting terraform will **need internet access** to apply the `matchbox-assets` terraform module. It will download the Container Linux OS assets and Tectonic Registry Cache ACI from our public mirrors and write a matchbox asset tarball out to local disk, along with a printout of asset URLs and a default terraform tfvar snippet to configure the terraform installer for offline duty.

  The asset tarball written to disk by this `matchbox-assets` terraform module is the entirety of the foreign bytes required for a Tectonic offline install- no further egress is required.

  ```sh
  # This example assumes you have been using the "make plan" and "make apply" targets to actuate terraform. You can also `terraform apply -var-file <your-tfvars> modules/matchbox-assets` if you prefer.

  $> make matchbox-assets-apply

  .... (this will download ~2GB of assets from this internet, can take some time)
  ....

  null_resource.matchbox-assets-tarball: Creation complete after 57s (ID: 2437325656581840672)
  Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

  Outputs:

  id = ba4e741ccb30761c309d7766588d60aae1805ed7
  matchbox_assets_tarball_path = /home/chom/src/coreos/tectonic-installer/build/chom-test-metal/matchbox/matchbox-assets-chom-test-metal.tgz
  registry_cache_aci_path = /home/chom/src/coreos/tectonic-installer/build/chom-test-metal/matchbox/assets/tectonic-registry-cache-1.7.9-tectonic.1.aci
  terraform_tfvars_snippet =
  // Put these variable definitions in your terraform.tfvars files for this cluster

  .... (default tfvar configuration)

  ```

  * Carefully read the output of the last command. If you are using matchbox built-in HTTP server to host the Tectonic Registry Cache ACI and Container Linux assets, then you can copy the entirety of `terraform_tfvars_snippet` output into your `terraform.tfvars` file without modification.

  * Ensure there are no conflicting variable definitions already in your terraform tfvars

  * Verify that asset URLs use the expected proctol, hostname, port and path. This is also a good time to double check what you find here against your DNS/DHCP configuration as well.

  * Run a `make plan/terraform plan`, check that the plan still succeeds with the additional tfvar configuration and has the correct state.

  * Copy the matchbox assets tarball from machine running terraform to the machine hosting matchbox (if they are separate). The machine hosting Matchbox **does not need internet access**.

  ```sh
  $> scp <matchbox_assets_tarball_path> user@matchbox_host:~/
  ```

  * On the `matchbox_host` machine, extract the assets tarball in correct location. This example assumes your matchbox assets directory is expected at the default location- `/var/lib/matchbox/assets`:

  ```sh
  $> tar -C /var/lib/matchbox/ -zxvf ~/<assets-tarball-name>.tgz
  ```

  * Verify you can download the individual asset files (ideally from within in your Tectonic node network) before continuing.

#### Step 3

  Resume the standard bare metal Tectonic install flow (at the correct version), and follow to completion.

### Notes

* Your cluster does not have internet access! If you don't have an image registry set up in your offline environment, that will most likely be the next step- along with figuring out how images get from the outside world and into your offline registry.

* The MAC address you list for each node in the tfvars must match the NIC that will used for network boot and node installation phases.

* Make sure to disable/disconnect any network interfaces you don't plan to use on your Tectonic hosts. Networkd will allow DHCP by default on any otherwise unconfigured NICs. This can be a very convenient way to multi-home your Tectonic nodes, but can cause problems if it occurs unintentionally. In both cases, there is potential for additional interfaces configurations conflicting with Tectonic network settings. (Most commonly around resolver's primary DNS server and default gateway)

* If you are configuring static ips:

  * there is no explicit need for DHCP reservations for the node MAC addresses.

  * If a network adapter name is not specified, networkd will pick the interface for the static address based on the provided MAC address for that node.

  * You can append additional networkd units to the [worker](/platforms/metal/cl/bootkube-worker.yaml.tmpl) and [controller](/platforms/metal/cl/bootkube-controller.yaml.tmpl) Container Linux Config templates before applying your terraform plan. This will allow you to further customize your Tectonic host networking (nic teaming, vlan tagging, MTU, etc).


