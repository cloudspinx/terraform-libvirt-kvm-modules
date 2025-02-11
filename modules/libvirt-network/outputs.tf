output "network_id" {
  description = "The ID of the created libvirt network"
  value       = try(libvirt_network.this[0].id, null)
}

output "network_name" {
  description = "The name of the libvirt network"
  value       = try(libvirt_network.this[0].name, null)
}
