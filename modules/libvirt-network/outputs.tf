output "network_id" {
  description = "The ID of the created libvirt network"
  value       = libvirt_network.this.id
}
