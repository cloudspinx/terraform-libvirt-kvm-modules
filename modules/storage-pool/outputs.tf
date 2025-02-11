output "pool_id" {
  description = "The ID of the created Libvirt storage pool"
  value       = try(libvirt_pool.storage[0].id, null)
}

output "name" {
  description = "The name of the created Libvirt storage pool"
  value       = try(libvirt_pool.storage[0].name, null)
}
