# Storage pool variables
variable "create_storage_pool" {
  description = "Whether to create the storage Libvirt storage pool"
  type        = bool
  default     = false
}

variable "storage_pool_name" {
  description = "The name of the storage Libvirt pool"
  type        = string
  default     = "vms_storage"
}

variable "storage_pool_path" {
  description = "The path where the storage Libvirt pool will be stored"
  type        = string
  default     = "/var/lib/libvirt/images"
}

# Domain variables

variable "vm_hostname_prefix" {
  description = "The prefix for the VM name"
  type        = string
  default     = "vm"
}

variable "vm_domain" {
  description = "The VM's domain that forms the FQDN."
  type        = string
  default     = "example.com"
}

variable "vcpu" {
  description = "The number of vCPUs for the instance"
  type        = number
  default     = 1
}

variable "cpu_mode" {
  description = "The CPU mode for the instance"
  type        = string
  default     = "host-passthrough"
}

variable "memory" {
  description = "The amount of memory for the instance (in MB)"
  type        = string
  default     = "1024"
}

variable "base_volume_name" {
  description = "Name of base OS image"
  type        = string
  default     = null
}

variable "os_name" {
  description = "The name of the os to use"
  type        = string
  default     = "ubuntu"
}

variable "os_version" {
  description = "The version of the os to use"
  type        = string
  default     = "latest"
}

variable "custom_image_path_url" {
  description = "Path to locally cached image or remote URL"
  type        = string
  default     = ""
}

variable "vm_autostart" {
  description = "Whether the instance should start automatically"
  type        = bool
  default     = true
}

variable "vm_count" {
  description = "The number of VMs to create"
  type        = number
  default     = 1
}

variable "index_start" {
  description = "The starting index for the VMs"
  type        = number
  default     = 1
}

variable "graphics" {
  description = "Graphics type for instance installation"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["spice", "vnc", "none"], var.graphics)
    error_message = "Graphics type not supported. Only 'spice', 'vnc', or 'none' are valid options."
  }
}

# VM Storage variables

variable "os_disk_size" {
  description = "OS disk size (in GB)"
  type        = number
  default     = "10"
}

variable "additional_disk_ids" {
  description = "List of volume ids"
  type        = list(string)
  default     = []
}

variable "share_filesystem" {
  type = object({
    source   = string
    target   = string
    readonly = bool
    mode     = string
  })
  default = {
    source   = null
    target   = null
    readonly = false
    mode     = null
  }
}

variable "create_additional_disk" {
  description = "Whether to create additional disks"
  type        = bool
  default     = false
}

variable "additional_disk_size" {
  description = "Additional disk size (in GB)"
  type        = number
  default     = 0
}

variable "additional_disk_count" {
  description = "Number of additional disks to attach"
  type        = number
  default     = 0
}

## Network sub-module variables

variable "create_network" {
  description = "Whether to create the libvirt network"
  type        = bool
  default     = false
}

variable "network_name" {
  description = "The name of the libvirt network"
  type        = string
  default     = "default"
}

variable "network_bridge" {
  description = "The bridge device for the network"
  type        = string
  default     = "virbr10"
}

variable "network_mode" {
  description = "The network mode (e.g., nat, bridge)"
  type        = string
  default     = "nat"
}

variable "network_mtu" {
  description = "The MTU for the network"
  type        = number
  default     = 1500
}

variable "network_autostart" {
  description = "Whether the network should autostart"
  type        = bool
  default     = true
}

variable "network_cidr" {
  description = "List of CIDR addresses for the network"
  type        = list(string)
  default     = ["172.21.0.0/24"]
}

variable "network_dhcp_enabled" {
  description = "Whether DHCP is enabled for the network"
  type        = bool
  default     = true
}

## Instance network variables
variable "network_interface" {
  description = "The network interface for the instance"
  type        = string
  default     = "ens3"
}

variable "use_dhcp" {
  description = "Whether to use DHCP or Static IP for the instance"
  type        = bool
  default     = true
}

variable "vm_ip_address" {
  description = "List of IP addresses for the instance"
  type        = list(string)
  default     = []
}

variable "vm_ip_gateway" {
  description = "The IP address of the gateway"
  type        = string
  default     = "192.168.122.1"
  }

  variable "vm_dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8","1.1.1.1"]
}

# Cloud-init variables

variable "package_update" {
  description = "Update the package list"
  type        = bool
  default     = true
}

variable "preserve_hostname" {
  description = "Preserve the hostname of the instance"
  type        = bool
  default     = false
}

variable "manage_etc_hosts" {
  description = "Manage the /etc/hosts file"
  type        = bool
  default     = true
}

variable "create_hostname_file" {
  description = "Create a hostname file for the instance"
  type        = bool
  default     = true
}

variable "prefer_fqdn_over_hostname" {
  description = "Prefer FQDN over hostname"
  type        = bool
  default     = true
}

variable "enable_ssh_pwauth" {
  description = "Enable ssh password login"
  type        = bool
  default     = false
}

variable "disable_root_login" {
  description = "Disable root user login"
  type        = bool
  default     = true
}

variable "lock_root_user_password" {
  description = "Lock root user password"
  type        = bool
  default     = true
}

variable "lock_user_password" {
  description = "Lock root user password"
  type        = bool
  default     = false
}

variable "set_root_password" {
  description = "Enable setting a root password"
  type        = bool
  default     = false
}

variable "set_user_password" {
  description = "Enable setting a root password"
  type        = bool
  default     = false
}

variable "ssh_user_name" {
  description = "The admin user name to created on the target instance"
  type        = string
  default     = "cloud"
}

variable "ssh_user_fullname" {
  description = "The full name of the admin user on the target instance"
  type        = string
  default     = "Cloud Admin"
}

variable "ssh_user_shell" {
  description = "The shell for the admin user on the target instance"
  type        = string
  default     = "/bin/bash"
}

variable "set_ssh_user_password" {
  description = "Enable setting a user password"
  type        = bool
  default     = false
}

variable "generate_ssh_keys" {
  description = "Generate SSH keys for the instance"
  type        = bool
  default     = true
}

variable "timezone" {
  description = "Time Zone"
  type        = string
  default     = "UTC"
}

variable "packages" {
  description = "Extra packages to install on the instance"
  type        = list(string)
  default     = [
    "qemu-guest-agent",
    "vim",
    "wget",
    "curl",
    "unzip",
    "git"
  ]
}

variable "runcmds" {
  description = "Extra commands to be run with cloud init"
  type        = list(string)
  default = [
    "[ systemctl, daemon-reload ]",
    "[ systemctl, enable, qemu-guest-agent ]",
    "[ systemctl, start, qemu-guest-agent ]",
    "[ systemctl, restart, systemd-networkd ]"
  ]
}

variable "ssh_keys" {
  description = "List of public ssh keys to add to the instance"
  type        = list(string)
  default     = []
}

variable "disable_ipv6" {
  description = "Disable IPv6 on the instance"
  type        = bool
  default     = false
}

# Bastion (maybe for future use in air-gapped environments)
variable "bastion_host" {
  description = "The bastion host to use for SSH connection"
  type        = string
  default     = ""
}

variable "bastion_user" {
  description = "The user to use for SSH connection to the bastion host"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "The private key to use for SSH connection to the bastion host"
  type        = string
  default     = ""
}
