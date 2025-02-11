resource "libvirt_network" "this" {
  count     = var.create_network ? 1 : 0
  name      = var.network_name
  autostart = var.network_autostart
  mode      = var.network_mode
  mtu       = var.network_mode != "bridge" ? var.network_mtu : null
  addresses = var.network_mode != "bridge" ? var.network_cidr : null

  bridge = var.network_mode == "bridge" ? var.network_bridge : null

  dynamic "dhcp" {
    for_each = var.network_mode == "nat" ? [1] : []
    content {
      enabled = var.network_dhcp_enabled
    }
  }
}
