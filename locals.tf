locals {
  vm_fqdn               = "${var.vm_hostname_prefix}.${var.vm_domain}"
  # Hash the user password
  root_password_hash = var.set_root_password ? bcrypt(random_password.root_password[0].result) : null
  user_password_hash = var.set_user_password ? bcrypt(random_password.user_password[0].result) : null

  # SSH connection
  ssh_public_key  = var.generate_ssh_keys ? chomp(tls_private_key.ssh_key.public_key_openssh) : chomp(file(var.ssh_public_key))
  ssh_private_key = var.generate_ssh_keys ? chomp(tls_private_key.ssh_key.private_key_pem) : chomp(file(var.ssh_private_key))
  vm_ip           = var.network_config == "" ? libvirt_domain.this_domain.network_interface.0.addresses[0] : ""
  connection      = "ssh ${var.ssh_user_name}@${local.ip}"
}
