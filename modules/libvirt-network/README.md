## Libvirt network module

The [network sub-module](https://github.com/cloudspinx/terraform-libvirt-kvm-modules/tree/main/modules/libvirt-network) allows you to create and destroy libvirt networks.

### Inputs

| Name                   | Description                                 | Type         | Default                 |
|------------------------|---------------------------------------------|--------------|-------------------------|
| `create_network`       | Whether to create the libvirt network       | bool         | `false`                 |
| `network_name`         | The name of the libvirt network             | string       | `"private"`             |
| `network_bridge`       | The bridge device for the network           | string       | `"virbr10"`             |
| `network_mode`         | The network mode (e.g., nat, bridge)        | string       | `"nat"`                 |
| `network_mtu`          | The MTU for the network                     | number       | `1500`                  |
| `network_autostart`    | Whether the network should autostart        | bool         | `true`                  |
| `network_cidr`         | List of CIDR addresses for the network      | list(string) | `["172.21.0.0/24"]`     |
| `network_dhcp_enabled` | Whether DHCP is enabled for the network     | bool         | `true`                  |

### Outputs

| Name         | Description                          |
|-------------|--------------------------------------|
| `network_id` | The ID of the created libvirt network |
| `name`       | The name of the libvirt network      |

### Example 1: Create nat libvirt network

This example creates nat libvirt network:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.8.3"
      }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
  #uri = "qemu+ssh://root@192.168.1.7/system"
}

module "libvirt_network" {
  source            = "git::https://github.com/cloudspinx/terraform-kvm-modules.git//modules/libvirt-network?ref=main"
  create_network    = true
  network_name      = "private"
  network_mode      = "nat"
  network_mtu       = 1500
  network_cidr      = ["172.24.30.0/24"]
  network_autostart = true
}
```

Run terraform commands to create network:

```bash
terraform init
terraform apply
```

Validate:

```bash
# virsh  net-list
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
 private   active   yes         yes

# virsh net-dumpxml private
```

### Example 2: Create libvirt network on existing host bridge

List configured bridge(s) on the host:

```bash
# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.22d1dfd71e10	no		enp89s0
```

Creating libvirt network using terraform

```hcl
module "libvirt_network" {
  # Note that cidr and mtu are missing. This is often managed externally in bridged networks - network switch / router.
  source            = "git::https://github.com/cloudspinx/terraform-kvm-modules.git//modules/libvirt-network?ref=main"
  create_network    = true
  network_name      = "br0"     # Good to use same name as bridge name
  network_mode      = "bridge"  # Set network mode to bridge
  network_bridge    = "br0"     # Name of host bridge to use
  network_autostart = true
}
```

Create and confirm:

```bash
terraform plan
terraform init -upgrade
terraform apply
virsh net-list
```