# terraform-kvm-modules

Repository containing KVM terraform modules

Define backend

```hcl
$ vim backend.tf
terraform {
  backend "local" {
    # Path to store the state file
    path = "terraform.tfstate"  # Use a static path (cannot use dynamic values like ${path.module})
    # path = "${path.module}/terraform.tfstate"
  }
}
  # Uncomment the following block to use an S3 backend
  # backend "s3" {
  #   bucket         = "your-s3-bucket-name"
  #   key            = "path/to/your/state.tfstate"
  #   region         = "us-east-1"
  #   access_key     = "your-access-key"
  #   secret_key     = "your-secret-key"
  #   encrypt        = true
  # }

  # Uncomment the following block to use a Kubernetes ConfigMap for state storage
  # backend "kubernetes" {
  #   secret_namespace = "kube-system"
  #   secret_name      = "terraform-state"
  #   key              = "state-file-key"
  #   config_path      = "~/.kube/config"
  # }
```

Create `providers.tf` file:

```hcl
$ vim providers.tf
terraform {
  # required_version = ">= 1.0"
  required_providers {
    libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.8.1"
      }
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.6"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "libvirt" {
  #uri = "qemu:///system"
  uri = "qemu+ssh://root@192.168.1.7/system"
}
provider "random" {
  # Configuration options
}
provider "tls" {
  # Configuration options
}
provider "local" {
  # Configuration options
}
provider "template" {
  # Configuration options
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
