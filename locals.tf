locals {
  vm_fqdn               = "${var.vm_hostname_prefix}.${var.vm_domain}"
  # Hash the user password
  root_password_hash = var.set_root_password ? bcrypt(random_password.root_password[0].result) : "null"
  user_password_hash = var.set_user_password ? bcrypt(random_password.user_password[0].result) : "null"

  # SSH connection
  generated_ssh_keys = var.generate_ssh_keys ? [trimspace(tls_private_key.ssh_key[0].public_key_openssh)] : []
  combined_ssh_keys  = concat(var.ssh_keys, local.generated_ssh_keys)
  # vm_ip           = var.network_config == "" ? libvirt_domain.this_domain[0].network_interface.0.addresses[0] : ""
  # connection      = "ssh ${var.ssh_user_name}@${local.vm_ip}"
}
