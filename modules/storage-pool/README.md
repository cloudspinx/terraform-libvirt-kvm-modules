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
        version = "0.8.3"
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