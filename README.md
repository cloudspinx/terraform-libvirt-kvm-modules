# Terraform modules to create libvirt storage pools, networks, and vm domains

This repository contains Terraform module for managing KVM resources.

## Requirements
The following are the main requirements for using the module to create instances on KVM using the module

- [Terraform](https://developer.hashicorp.com/terraform/install) or [OpenTofu](https://opentofu.org/docs/intro/install/)
- [Libvirt provider](https://github.com/dmacvicar/terraform-provider-libvirt)

All terraform providers Used:

- libvirt (source: dmacvicar/libvirt)
- random (source: hashicorp/random)
- tls (source: hashicorp/tls)
- local (source: hashicorp/local)
- template (source: hashicorp/template)


## Libvirt storage pool module

We provide a [storage sub-module](https://github.com/cloudspinx/terraform-libvirt-kvm-module/tree/main/modules/storage-pool) in the repository that can be used to create storage pools independently.

### Inputs

| Name                | Description                                      | Type    | Default                  |
|---------------------|--------------------------------------------------|--------|--------------------------|
| `storage_pool_name` | The name of the storage Libvirt pool             | string | `"vms_storage"`          |
| `create_storage_pool` | Whether to create the storage Libvirt storage pool | bool   | `true`                   |
| `storage_pool_path` | The path where the storage Libvirt pool will be stored | string | `"/var/lib/libvirt/images"` |

### Outputs

| Name     | Description                                   |
|----------|-----------------------------------------------|
| `pool_id` | The ID of the created Libvirt storage pool  |
| `name`    | The name of the created Libvirt storage pool |

Usage example:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.8.1"
      }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
  #uri = "qemu+ssh://root@192.168.1.7/system"
}

module "storage_pool" {
  source              = "git::https://github.com/cloudspinx/terraform-kvm-modules.git//modules/storage-pool?ref=main"
  create_storage_pool = true
  storage_pool_name   = "vms_pool"       # Set to name you want to use
  storage_pool_path   = "/data/vms_pool" # Path to use for the pool. Make sure not used by another pool `virsh pool-list`
}
```

Then create storage pool resource:

```bash
terraform init
terraform plan
terraform apply
```

Confirm creation:

```bash
# virsh pool-list
 Name       State    Autostart
--------------------------------
 default    active   yes
 vms_pool   active   yes
```

## Libvirt network module

The [network sub-module](https://github.com/cloudspinx/terraform-libvirt-kvm-modules/tree/main/modules/storage-pool) allows you to create and destroy libvirt networks.

### Inputs

| Name                  | Description                                 | Type         | Default                 |
|-----------------------|---------------------------------------------|-------------|-------------------------|
| `create_network`      | Whether to create the libvirt network      | bool        | `false`                 |
| `network_name`        | The name of the libvirt network            | string      | `"private"`             |
| `network_bridge`      | The bridge device for the network          | string      | `"virbr10"`             |
| `network_mode`        | The network mode (e.g., nat, bridge)       | string      | `"nat"`                 |
| `network_mtu`        | The MTU for the network                    | number      | `1500`                  |
| `network_autostart`   | Whether the network should autostart       | bool        | `true`                  |
| `network_cidr`       | List of CIDR addresses for the network     | list(string) | `["172.21.0.0/24"]`     |
| `network_dhcp_enabled` | Whether DHCP is enabled for the network   | bool        | `true`                  |

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
        version = "0.8.1"
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
  network_cidr      = "[172.24.30.0/24"]
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

## Cloud images module

To streamline instance creation, we created a [cloud images management module](https://github.com/cloudspinx/terraform-libvirt-kvm-modules/tree/main/modules/os-images)

### 1. Automatic image download (Default) - using the module

- Users can specify `os_name`, and optionally a `version`.  
- If `version` is not provided, the latest available version is used.  
- Terraform will automatically download the required cloud image during provisioning.

Table of images populated into sub-module: `modules/os-images`:

#### Supported OS Images

If version is not specified, it will default to using the latest version for that os.

| **OS Name**       | **Version** | **Latest Version(Default choice)** |
|-------------------|------------|--------------------|
| **ubuntu**       | latest     | 24.04              |
|                 | 24.04      |                    |
|                 | 20.04      |                    |
|                 | 18.04      |                    |
|                 | 16.04      |                    |
| **rockylinux**   | latest     | 9                  |
|                 | 9          |                    |
|                 | 8          |                    |
| **almalinux**    | latest     | 9                  |
|                 | 9          |                    |
|                 | 8          |                    |
| **oraclelinux**  | latest     | 9                  |
|                 | 9          |                    |
|                 | 8          |                    |
| **centos-stream**| latest     | 9                  |
|                 | 9          |                    |
| **debian**       | latest     | 12                 |
|                 | 12         |                    |
|                 | 11         |                    |
|                 | 10         |                    |
| **fedora**       | latest     | 41                 |
|                 | 40         |                    |
| **alpine**       | latest     | 3.21               |
|                 | 3.20       |                    |
| **amazonlinux**  | latest     | 2023               |
| **opensuse**     | latest     | 15.6               |
|                 | 15.5       |                    |
| **archlinux**   | latest     | latest             |
| **freebsd**      | latest     | 14                 |
|                 | 13         |                    |


#### 2. Cached Image Approach (Recommended for slow networks)  

- Instead of downloading the image every time, users can pre-cache frequently used images locally.  
- The module allows specifying a local path for the image, bypassing the need for downloads.  
- This approach is particularly useful in development environments where instances are frequently created and destroyed. Or if bandwidth is an issue.


```bash
IMAGE_PATH="/home/os-images" # Define path to store cloud images
mkdir -p /home/os-images     # Create directory where images are cached
cd /home/os-images           # Naviage to the directory
wget <cloud-image-url>       # Download remote cloud image locally
```

To use the cached image method, simply set `custom_image_path_url` to the local path of the pre-downloaded image. If left empty, the module will revert to automatic image downloading. The default image chosen in latest Ubuntu LTS, which at the time of updating this content it's `24.04`.

The `custom_image_path_url` can also be used to specify remote custom link to a cloud image to be downloaded. See below examples.

```bash
# Example
custom_image_path_url = "file:///home/os-images/ubuntu-latest.qcow2"
```

The `custom_image_path_url` can also be used to specify custom image URL:
```bash
custom_image_path_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
```

### Creating `main.tf` file

In your `main.tf` file define required providers and ini

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.8.1"
      }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
  #uri = "qemu+ssh://root@192.168.1.7/system"
}
```


Identify available storage pools:

```bash
$ virsh pool-list
 Name             State    Autostart
--------------------------------------
 dirpool          active   yes
 images           active   yes
 virt-lightning   active   no
```

Identify available libvirt networks:

```bash
$ virsh net-list
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
```

### Libvirt Network Sub-Module

This Terraform sub-module creates and manages a Libvirt network with configurable options such as mode, DHCP, MTU, and bridge settings.

#### Usage

```hcl
module "libvirt_network" {
  source = "./modules/libvirt-network"

  network_name  = "private_net"
  bridge        = "virbr20"
  mode          = "nat"
  mtu           = 1400
  autostart     = true
  addresses     = ["192.168.100.0/24"]
  dhcp_enabled  = true
}
```

#### Inputs

| Name           | Description                            | Type           | Default             |
| -------------- | -------------------------------------- | -------------- | ------------------- |
| `network_name` | The name of the Libvirt network        | `string`       | "private"           |
| `bridge`       | The bridge device for the network      | `string`       | "virbr10"           |
| `mode`         | The network mode (`nat`, `bridge`)     | `string`       | "nat"               |
| `mtu`          | The MTU for the network                | `number`       | `1500`              |
| `autostart`    | Whether the network should autostart   | `bool`         | `true`              |
| `addresses`    | List of CIDR addresses for the network | `list(string)` | `["172.21.0.0/24"]` |
| `dhcp_enabled` | Whether DHCP is enabled for NAT mode   | `bool`         | `true`              |

#### Outputs

| Name         | Description                           |
| ------------ | ------------------------------------- |
| `network_id` | The ID of the created Libvirt network |




#### Notes
- **Bridge mode** requires setting a valid bridge name in bridge.
- **NAT mode** supports DHCP, which can be enabled or disabled using dhcp_enabled.
- **Validation** ensures addresses contain valid CIDR blocks.

## Tips and Tricks

Cleaning broken VM creation (bad terraform state)

```bash
VM_NAME="server01"
POOL_NAME="default"
sudo virsh destroy $VM_NAME       # Force shutdown the VM
sudo virsh undefine --remove-all-storage $VM_NAME      # Remove the VM from libvirt
sudo virsh list --all

terraform state rm module.vm.libvirt_domain.this_domain
terraform destroy -auto-approve
```

### Solving Could not open '/var/lib/libvirt/images/<FILE_NAME>': Permission denied
The [Issue link](https://github.com/dmacvicar/terraform-provider-libvirt/commit/22f096d9)

A quick solution is to disable QEMU default security driver.

```bash
$ sudo nano /etc/libvirt/qemu.conf
security_driver = "none"
```

Then restart `libvirtd` service after making the changes:

```bash
sudo systemctl restart libvirtd
```
