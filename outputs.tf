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

output "hostname_ip_map" {
  value = {
    for idx, vm in libvirt_domain.this_domain :
    vm.name => try(vm.network_interface[0].addresses[0], "N/A")
  }
}

output "ssh_commands" {
  value = {
    for idx, vm in libvirt_domain.this_domain :
    vm.name => format("ssh -i %s %s@%s", "${path.cwd}/sshkey.priv", var.ssh_user_name, try(vm.network_interface[0].addresses[0], "N/A"))
  }
}
