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

variable "os_storage_pool_name" {
  description = "Name of base OS image"
  type        = string
  default     = "default"
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

variable "os_cached_image" {
  description = "If the os image you wish to use is cached locally then set the path to it in this variable"
  type        = string
  default     = ""
}

variable "os_img_url" {
  description = "The URL of the OS cloud image to use as base for the instance"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "autostart" {
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

# Storage variables
variable "create_default_pool" {
  description = "Create a default storage pool"
  type        = bool
  default     = false
}

variable "storage_pool" {
  description = "The storage pool to use for instance volumes"
  type        = string
  default     = "default"
}

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

# Networking variables

variable "network_config" {
  description = "A user defined cloudinit network config"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "The name of the default network to use for the instance"
  type        = string
  default     = "default"
}
variable "use_dhcp" {
  description = "Whether to use DHCP or Static IP for the instance"
  type        = bool
  default     = true
}

variable "bridge_name" {
  description = "The name of the bridge to use for the instance"
  type        = string
  default     = "virbr0"
}

variable "ip_address" {
  description = "List of IP addresses for the instance"
  type        = list(string)
  default     = ["192.168.122.101"]
}

variable "ip_gateway" {
  description = "The IP address of the gateway"
  type        = string
  default     = "192.168.122.1"
  }

  variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["192.168.122.1"]
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

variable "enable_root_password" {
  description = "Enable root password"
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
  default     = true
}


variable "expire_root_user_pass" {
  description = "Expire root user password on first login"
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
variable "ssh_private_key" {
  description = "Private key for SSH connection test (either path to file or key content)"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  description = "The path to SSH public key to use for the instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
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

# Bastion
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
