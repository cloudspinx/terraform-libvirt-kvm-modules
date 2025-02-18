# Terraform modules to create libvirt storage pools, networks, and vm domains

This repository contains Terraform module for managing KVM resources.

## Requirements
The following are the main requirements for using the module to create instances on KVM using the module

- [Terraform](https://developer.hashicorp.com/terraform/install) or [OpenTofu](https://opentofu.org/docs/intro/install/)
- [Libvirt provider](https://github.com/dmacvicar/terraform-provider-libvirt)

All terraform providers used:

- libvirt (source: dmacvicar/libvirt)
- random (source: hashicorp/random)
- tls (source: hashicorp/tls)
- local (source: hashicorp/local)
- template (source: hashicorp/template)

## 1. Libvirt storage pool module

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

## 2. Libvirt network module

The [network sub-module](https://github.com/cloudspinx/terraform-libvirt-kvm-modules/tree/main/modules/libvirt-network) allows you to create and destroy libvirt networks.

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

## 3. Cloud images module

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

Usage example:

```bash
# Ubuntu 24.04 cloud image
os_name             = "ubuntu"
os_version          = "24.04"

# AlmaLinux 8 cloud image
os_name             = "almalinux"
os_version          = "8"

# If you just provide the os_name, then latest release is used:
os_name             = "debian"
```

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

## 4. Libvirt domains module

The root of this repository is the domain creation module. The module provides an automated way to deploy virtual machines (VMs) using Libvirt. It includes configurable options for storage, networking, cloud-init, and other VM settings.

### Other dependent resources

This module relies on the following extra terraform resources:

| Resource Name            | Description |
|--------------------------|-------------|
| `random_password.root_password` | Generates a random root password if `set_root_password` is enabled. |
| `random_password.user_password` | Generates a random user password if `set_user_password` is enabled. |
| `random_id.uuid` | Generates a unique identifier prefixed with the OS name and version. |
| `tls_private_key.ssh_key` | Creates an RSA SSH key pair if `generate_ssh_keys` is enabled. |
| `local_file.root_password` | Stores the generated root password in a local file if `set_root_password` is enabled. |
| `local_file.user_password` | Stores the generated user password in a local file if `set_user_password` is enabled. |
| `local_file.ssh_private_key` | Saves the private SSH key to a file if `generate_ssh_keys` is enabled. |
| `local_file.ssh_public_key` | Saves the public SSH key to a file if `generate_ssh_keys` is enabled. |

Each resource is conditionally created based on module variables to provide flexibility.

### Inputs

#### Storage Pool Variables

| Variable              | Description                                            | Type     | Default                   |
| --------------------- | ------------------------------------------------------ | -------- | ------------------------- |
| `create_storage_pool` | Whether to create the Libvirt storage pool             | `bool`   | `false`                   |
| `storage_pool_name`   | The name of the Libvirt storage pool                   | `string` | `vms_storage`             |
| `storage_pool_path`   | The path where the Libvirt storage pool will be stored | `string` | `/var/lib/libvirt/images` |

#### Domain Variables

| Variable                | Description                                                             | Type     | Default            |
| ----------------------- | ----------------------------------------------------------------------- | -------- | ------------------ |
| `vm_hostname_prefix`    | The prefix for the VM name                                              | `string` | `vm`               |
| `vm_domain`             | The VM's domain that forms the FQDN                                     | `string` | `example.com`      |
| `vcpu`                  | The number of vCPUs for the instance                                    | `number` | `1`                |
| `cpu_mode`              | The CPU mode for the instance                                           | `string` | `host-passthrough` |
| `memory`                | The amount of memory for the instance (in MB)                           | `string` | `1024`             |
| `base_volume_name`      | Name of the base OS image                                               | `string` | `null`             |
| `os_name`               | The name of the OS to use                                               | `string` | `ubuntu`           |
| `os_version`            | The version of the OS to use                                            | `string` | `latest`           |
| `custom_image_path_url` | Path to locally cached image or remote URL                              | `string` | `""`               |
| `vm_autostart`          | Whether the instance should start automatically                         | `bool`   | `true`             |
| `vm_count`              | The number of VMs to create                                             | `number` | `1`                |
| `index_start`           | The starting index for the VMs                                          | `number` | `1`                |
| `graphics`              | Graphics type for instance installation (Valid: `spice`, `vnc`, `none`) | `string` | `none`             |

#### VM Storage Variables

| Variable              | Description                     | Type           | Default                                                       |
| --------------------- | ------------------------------- | -------------- | ------------------------------------------------------------- |
| `os_disk_size`        | OS disk size (in GB)            | `number`       | `10`                                                          |
| `additional_disk_ids` | List of volume IDs              | `list(string)` | `[]`                                                          |
| `share_filesystem`    | Shared filesystem configuration | `object`       | `{ source: null, target: null, readonly: false, mode: null }` |

#### Network Variables

| Variable               | Description                             | Type           | Default                  |
| ---------------------- | --------------------------------------- | -------------- | ------------------------ |
| `create_network`       | Whether to create the Libvirt network   | `bool`         | `false`                  |
| `network_name`         | The name of the Libvirt network         | `string`       | `default`                |
| `network_bridge`       | The bridge device for the network       | `string`       | `virbr10`                |
| `network_mode`         | The network mode (`nat`, `bridge`)      | `string`       | `nat`                    |
| `network_mtu`          | The MTU for the network                 | `number`       | `1500`                   |
| `network_autostart`    | Whether the network should autostart    | `bool`         | `true`                   |
| `network_cidr`         | List of CIDR addresses for the network  | `list(string)` | `["172.21.0.0/24"]`      |
| `network_dhcp_enabled` | Whether DHCP is enabled for the network | `bool`         | `true`                   |
| `use_dhcp`             | Whether to use DHCP or Static IP        | `bool`         | `true`                   |
| `vm_ip_address`        | List of IP addresses for the instance   | `list(string)` | `["192.168.122.101/24"]` |
| `vm_ip_gateway`        | The IP address of the gateway           | `string`       | `192.168.122.1`          |
| `vm_dns_servers`       | List of DNS servers                     | `list(string)` | `["8.8.8.8", "1.1.1.1"]` |

#### Cloud-Init Variables

| Variable                    | Description                             | Type           | Default                                                                       |
| --------------------------- | --------------------------------------- | -------------- | ----------------------------------------------------------------------------- |
| `package_update`            | Update the package list                 | `bool`         | `true`                                                                        |
| `preserve_hostname`         | Preserve the hostname of the instance   | `bool`         | `false`                                                                       |
| `manage_etc_hosts`          | Manage the `/etc/hosts` file            | `bool`         | `true`                                                                        |
| `create_hostname_file`      | Create a hostname file for the instance | `bool`         | `true`                                                                        |
| `prefer_fqdn_over_hostname` | Prefer FQDN over hostname               | `bool`         | `true`                                                                        |
| `enable_ssh_pwauth`         | Enable SSH password authentication      | `bool`         | `false`                                                                       |
| `disable_root_login`        | Disable root user login                 | `bool`         | `true`                                                                        |
| `lock_root_user_password`   | Lock root user password                 | `bool`         | `true`                                                                        |
| `set_root_password`         | Enable root password                    | `bool`         | `false`                                                                       |
| `set_user_password`         | Enable setting a user password          | `bool`         | `true`                                                                        |
| `ssh_user_name`             | Admin username for the instance         | `string`       | `cloud`                                                                       |
| `ssh_user_fullname`         | Full name of the admin user             | `string`       | `Cloud Admin`                                                                 |
| `ssh_user_shell`            | Shell for the admin user                | `string`       | `/bin/bash`                                                                   |
| `generate_ssh_keys`         | Generate SSH keys for the instance      | `bool`         | `true`                                                                        |
| `timezone`                  | Time Zone                               | `string`       | `UTC`                                                                         |
| `packages`                  | Extra packages to install               | `list(string)` | `["qemu-guest-agent", "vim", "wget", "curl", "unzip", "git"]`                 |
| `runcmds`                   | Extra cloud-init commands               | `list(string)` | `["[ systemctl, daemon-reload ]", "[ systemctl, enable, qemu-guest-agent ]"]` |
| `ssh_keys`                  | List of public SSH keys to add          | `list(string)` | `[]`                                                                          |
| `disable_ipv6`              | Disable IPv6 on the instance            | `bool`         | `false`                                                                       |

#### Bastion Variables (For Air-Gapped Environments)

| Variable       | Description                      | Type     | Default |
| -------------- | -------------------------------- | -------- | ------- |
| `bastion_host` | Bastion host for SSH connections | `string` | `""`    |
| `bastion_user` | SSH user for the bastion host    | `string` | `""`    |


### Outputs

| Output Name | Description | Sensitive |
| --- | --- | --- |
| `ssh_user_name` | The SSH username for connecting to the VMs | No  |
| `root_password` | The root password (if set) | Yes |
| `user_password` | The user password (if set) | Yes |
| `all_vm_ips` | A map of VM names to their assigned IP addresses | No  |
| `ssh_commands` | SSH connection commands for each VM | No  |

### Usage

In your `main.tf` file define required providers and initialize.

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

If you're not using Terraform to create storage pools, list the available ones on your KVM host.

```bash
$ virsh pool-list
 Name             State    Autostart
--------------------------------------
 dirpool          active   yes
 images           active   yes
 virt-lightning   active   no
```

If you're using pre-created libvirt networks, list the available ones on your KVM host.

```bash
$ virsh net-list
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
```

### Example 1: Create storage pool, network and single Ubuntu 24.04 instance with sub-modules

```hcl
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

module "vm" {
  source              = "git::https://github.com/cloudspinx/terraform-kvm-modules.git?ref=main"
  vm_hostname_prefix  = "webserver"
  vm_domain           = "mylab.net"
  os_name             = "ubuntu"
  os_version          = "24.04"
  vm_count            = 1
  memory              = "2048"
  vcpu                = 1
  os_disk_size        = 20
  timezone            = "Africa/Nairobi"

  # Network sub-module
  create_network      = true
  network_name        = "private"
  network_mode        = "nat"
  network_cidr        = ["192.168.20.0/24"]

  # Storage pool
  create_storage_pool = true
  storage_pool_name   = "instances_pool"
  storage_pool_path   = "/mnt/vms_data"
}

output "ssh_username" {
  value = module.vm.ssh_user_name
}

output "ssh_commands" {
  value = module.vm.ssh_commands
}

output "all_vm_ips" {
  value = module.vm.all_vm_ips
}
```

In the output you will get the ssh commands into the created vm.

```bash
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

all_vm_ips = {
  "webserver01" = "192.168.20.216"
}
ssh_commands = {
  "webserver01" = "ssh -i /root/tf/sshkey.priv cloud@192.168.20.216"
}
ssh_username = "cloud"
```
Test ssh
```bash
ssh -i /root/tf/sshkey.priv cloud@192.168.20.216
```

#### Notes:

- The default user created is called `cloud`. But this can be overriden with:

```bash
ssh_user_name = "username"
```
- By default, SSH private and public keys are generated and stored in the current directory (where the `main.tf` file is located). To disable this, set the `generate_ssh_keys` variable to `false`.

```bash
$ ls  sshkey*
sshkey.priv  sshkey.pub
```
The SSH private key is `sshkey.priv` and the ssh public key is `sshkey.pub`. As default, the ssh public key will be added to the cloud user authorized keys list in the VM using cloud-init.

- Passing an additional list of SSH public keys to be added:

```bash
ssh_keys = [
  "ssh-pubkey-1",
  "ssh-pubkey-2"
]
```

- If `set_user_password` is set to true, a random password is generated, assigned to the user, and saved in user_password.txt:

```bash
$ ls user_password.txt
user_password.txt
```

And the same is true for root password if `set_root_password` is true. It will create `root_password.txt`

- To enable SSH password authentication for the `cloud` user (NOT RECOMMENDED). It is advised to use SSH keys for better security.

```bash
enable_ssh_pwauth     = true
set_user_password     = true
set_ssh_user_password = true
```

You can also enable root user login, but with ssh keys only.

```bash
disable_root_login    = false
```

You will then login by:

```bash
ssh -i sshkey.priv root@IP
```

- Customizing default user details:

```bash
ssh_user_name = "cloud"
ssh_user_fullname = "Cloud Admin"
```
- Setting the default list of packages to install on first boot

```bash
packages = [
    "qemu-guest-agent",
    "vim",
    "wget",
    "curl",
    "unzip",
    "git",
    "php"
  ]
```

- List of commands to run on first boot

```bash
runcmds = = [
    "[ systemctl, daemon-reload ]",
    "[ systemctl, enable, qemu-guest-agent ]",
    "[ systemctl, start, qemu-guest-agent ]",
    "[ systemctl, restart, systemd-networkd ]"
  ]
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
