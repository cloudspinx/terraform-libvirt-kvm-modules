output "ssh_uer_name" {
  value = var.ssh_uer_name
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
  value = var.generate_ssh_keys ? tls_private_key.ssh_key.private_key_pem : ""
  sensitive=true
}

output "public_key" {
  value = var.generate_ssh_keys ? tls_private_key.ssh_key.public_key_openssh : ""
  sensitive=true
}
