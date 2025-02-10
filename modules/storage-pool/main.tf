resource "libvirt_pool" "storage" {
  count = var.create_storage_pool ? 1 : 0

  name = var.storage_pool_name
  type = "dir"

  target {
    path = var.storage_pool_path
  }
}
