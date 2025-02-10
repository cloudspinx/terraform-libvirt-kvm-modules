# Terraform modules to create network, storage pool, and libvirt domains

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


## Preparation

### Storage Pool Manual Creation (Optional)

If you want your storage pool to persist beyond Terraform-managed resources, consider **manually** creating the `default` storage pool. Otherwise, let the module handle its creation for you.

```bash
sudo virsh pool-list  # Identify available storage pools
POOL_PATH="/data/vms" # Chaneg to the path you wan to use
POOL_NAME="default"   # Define the name of default storage pool
sudo mkdir -p $POOL_PATH
virsh pool-define-as --name $POOL_NAME --type dir --target $POOL_PATH
virsh pool-build $POOL_NAME
virsh pool-start $POOL_NAME
virsh pool-autostart $POOL_NAME
virsh pool-list --all
```

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

### Managing Cloud Image Sources  

To streamline instance creation, this module provides two options for sourcing cloud images:  

#### 1. Automatic Image Download (Default)  
- Users can specify `os_name`, and optionally a `version`.  
- If `version` is not provided, the latest available version is used.  
- Terraform will automatically download the required cloud image during provisioning.

Table of images populated into sub-module: `modules/os-images`:

# Supported OS Images

| **OS Name**       | **Version** | **Latest Version** |
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


#### 2. Cached Image Approach (Recommended for Faster Deployments)  
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
custom_image_path_url = "/home/os-images/ubuntu-latest.qcow2"
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
