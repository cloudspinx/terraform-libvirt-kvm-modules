variable "network_name" {
  description = "The name of the libvirt network"
  type        = string
  default     = "private"
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
