resource "libvirt_network" "network" {
  name      = var.network_name
  mode      = var.mode
  mtu       = var.mtu
  autostart = var.autostart
  addresses = var.addresses

  dynamic "bridge" {
    for_each = var.mode == "bridge" && var.bridge != "" ? [1] : []
    content {
      bridge = var.bridge
    }
  }

  dynamic "dhcp" {
    for_each = var.mode == "nat" ? [1] : []
    content {
      enabled = var.dhcp_enabled
    }
  }
}

output "network_id" {
  description = "The ID of the created libvirt network"
  value       = libvirt_network.network.id
}
