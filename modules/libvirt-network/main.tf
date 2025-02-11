resource "libvirt_network" "this" {
  name      = var.network_name
  mode      = var.network_mode
  mtu       = var.network_mtu
  autostart = var.network_autostart
  addresses = var.network_cidr

  bridge = var.network_mode == "bridge" ? var.network_bridge : null

  dynamic "dhcp" {
    for_each = var.network_mode == "nat" ? [1] : []
    content {
      enabled = var.network_dhcp_enabled
    }
  }
}
