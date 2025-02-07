output "ssh_user_name" {
  value = var.ssh_user_name
}

output "root_password" {
  sensitive = true
  value = var.set_root_password ? random_password.root_password[0].result : ""
}

output "user_password" {
  sensitive = true
  value     = var.set_user_password ? random_password.user_password[0].result : ""
}

output "private_key" {
  value = var.generate_ssh_keys ? tls_private_key.ssh_key[0].private_key_pem : ""
  sensitive=true
}

output "public_key" {
  value = var.generate_ssh_keys ? tls_private_key.ssh_key[0].public_key_openssh : ""
  sensitive=true
}

# output "ip_address" {
#   value = libvirt_domain.this_domain[*].network_interface[0].addresses[0]
# }

# output "name" {
#   value = libvirt_domain.this_domain[*].name
# }
