variable "network_name" {
  description = "The name of the libvirt network"
  type        = string
  default     = "private"
}

variable "bridge" {
  description = "The bridge device for the network"
  type        = string
  default     = "virbr10"
}

variable "mode" {
  description = "The network mode (e.g., nat, bridge)"
  type        = string
  default     = "nat"
}

variable "mtu" {
  description = "The MTU for the network"
  type        = number
  default     = 1500
}

variable "autostart" {
  description = "Whether the network should autostart"
  type        = bool
  default     = true
}

variable "addresses" {
  description = "List of CIDR addresses for the network"
  type        = list(string)
  default     = ["172.21.0.0/24"]

  validation {
    condition     = alltrue([for cidr in var.addresses : can(cidrnetmask(cidr))])
    error_message = "Each element in 'addresses' must be a valid CIDR block."
  }
}

variable "dhcp_enabled" {
  description = "Whether DHCP is enabled for the network"
  type        = bool
  default     = true
}
