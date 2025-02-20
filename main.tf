##########################################
# Livirt Sub-modules section
#########################################

# Storage Pool creation (sub-module)
module "storage_pool" {
  count               = var.create_storage_pool ? 1 : 0
  source              = "./modules/storage-pool"
  storage_pool_name   = var.storage_pool_name
  storage_pool_path   = var.storage_pool_path
}

# Network creation (sub-module)
module "network" {
  count                = var.create_network ? 1 : 0
  source               = "./modules/libvirt-network"
  network_name         = var.network_name
  network_autostart    = var.network_autostart
  network_mode         = var.network_mode
  network_bridge       = var.network_bridge
  network_mtu          = var.network_mtu
  network_dhcp_enabled = var.network_dhcp_enabled
  network_cidr         = var.network_cidr
}

# OS Image creation (sub-module)
module "os_image" {
  count      = var.custom_image_path_url == "" ? 1 : 0
  source     = "./modules/os-images"
  os_name    = var.os_name
  os_version = var.os_version
}

##########################################
# Main section
#########################################

# Random resource creation section
resource "random_password" "root_password" {
  count            = var.set_root_password ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "user_password" {
  count            = var.set_user_password ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_id" "uuid" {
  byte_length = 4
  prefix      = "${var.os_name}-${var.os_version}"
}

resource "tls_private_key" "ssh_key" {
  count     = var.generate_ssh_keys ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Files creation section
resource "local_sensitive_file" "root_password" {
  count           = var.set_root_password ? 1 : 0
  content         = random_password.root_password[0].result
  filename        = "${path.cwd}/root_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "user_password" {
  count           = var.set_user_password ? 1 : 0
  content         = random_password.user_password[0].result
  filename        = "${path.cwd}/user_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_private_key" {
  count           = var.generate_ssh_keys ? 1 : 0
  content         = tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.cwd}/sshkey.priv"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_public_key" {
  count           = var.generate_ssh_keys ? 1 : 0
  content         = tls_private_key.ssh_key[0].public_key_openssh
  filename        = "${path.cwd}/sshkey.pub"
  file_permission = "0600"
}

# Cloud-init configuration section
data "template_cloudinit_config" "config" {
  count         = var.vm_count
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/cloud_init.tpl",
    {
      timezone                  = var.timezone
      manage_etc_hosts          = var.manage_etc_hosts
      preserve_hostname         = var.preserve_hostname
      create_hostname_file      = var.create_hostname_file
      vm_hostname               = format("${var.vm_hostname_prefix}%02d", count.index + var.index_start)
      vm_fqdn                   = format("${var.vm_hostname_prefix}%02d.%s", count.index + var.index_start, var.vm_domain)
      prefer_fqdn_over_hostname = var.prefer_fqdn_over_hostname
      enable_ssh_pwauth         = var.enable_ssh_pwauth
      disable_root_login        = var.disable_root_login
      lock_root_user_password   = var.lock_root_user_password
      set_root_password         = var.set_root_password
      root_password             = local.root_password_hash
      ssh_user_name             = var.ssh_user_name
      ssh_user_fullname         = var.ssh_user_fullname
      ssh_user_shell            = var.ssh_user_shell
      ssh_user_password         = local.user_password_hash
      set_ssh_user_password     = var.set_user_password
      lock_user_password        = var.lock_user_password
      packages                  = var.packages
      runcmds                   = var.runcmds
      ssh_keys                  = local.combined_ssh_keys
      disable_ipv6              = var.disable_ipv6
      package_update            = var.package_update
    })
  }
}

data "template_cloudinit_config" "network" {
  count         = var.vm_count
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    filename     = "network.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/${var.use_dhcp == true ? "dhcp" : "static"}_network_config.tpl",
    {
      vm_ip_address    = element(var.vm_ip_address, count.index)
      vm_ip_gateway    = var.vm_ip_gateway
      vm_dns_servers   = var.vm_dns_servers
      nic              = var.network_interface
    })
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.vm_count
  name           = format("${var.vm_hostname_prefix}_init%02d.iso", count.index + 1)
  user_data      = data.template_cloudinit_config.config[count.index].rendered
  network_config = data.template_cloudinit_config.network[count.index].rendered
  pool           = var.create_storage_pool ? module.storage_pool[0].name : var.storage_pool_name
}

# Volume creation section
resource "libvirt_volume" "base_image" {
  count  = var.base_volume_name != null ? 0 : 1
  name   = format("${var.vm_hostname_prefix}-base-image.qcow2")
  pool   = var.create_storage_pool ? module.storage_pool[0].name : var.storage_pool_name
  source = var.custom_image_path_url == "" ? module.os_image[0].url : var.custom_image_path_url
  format = "qcow2"
}

resource "libvirt_volume" "vm_disk_qcow2" {
  count            = var.vm_count
  name             = format("${var.vm_hostname_prefix}%02d.qcow2", count.index + var.index_start)
  pool             = var.storage_pool_name
  size             = 1024 * 1024 * 1024 * var.os_disk_size
  base_volume_id   = var.base_volume_name != null ? null : element(libvirt_volume.base_image, 0).id
  base_volume_name = var.base_volume_name
  base_volume_pool = var.create_storage_pool ? module.storage_pool[0].name : var.storage_pool_name
  format           = "qcow2"
}

resource "libvirt_volume" "additional_disk" {
  count  = var.create_additional_disk ? var.vm_count * var.additional_disk_count : 0
  name   = format("${var.vm_hostname_prefix}%02d-disk%02d.qcow2", floor(count.index / var.additional_disk_count) + var.index_start, (count.index % var.additional_disk_count) + 1)
  pool   = var.create_storage_pool ? module.storage_pool[0].name : var.storage_pool_name
  size   = 1024 * 1024 * 1024 * var.additional_disk_size
  format = "qcow2"
}


# Domains creation section
resource "libvirt_domain" "this_domain" {
  count  = var.vm_count
  name   = format("${var.vm_hostname_prefix}%02d", count.index + var.index_start)
  memory = var.memory
  cpu {
    mode = var.cpu_mode
  }
  vcpu       = var.vcpu
  autostart  = var.vm_autostart
  qemu_agent = true

  cloudinit = element(libvirt_cloudinit_disk.commoninit[*].id, count.index)

  network_interface {
    #bridge         = var.bridge_name
    network_name   = module.network[0].network_name
    wait_for_lease = true
    hostname       = format("${var.vm_hostname_prefix}%02d", count.index + var.index_start)
  }

  # xml {
  #   xslt = templatefile("${path.module}/xslt/template.tftpl", var.xml_override)
  # }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.vm_disk_qcow2[*].id, count.index)
  }

  dynamic "disk" {
  for_each = var.create_additional_disk ? range(var.additional_disk_count) : []
  content {
    volume_id = libvirt_volume.additional_disk[(count.index * var.additional_disk_count) + disk.value].id
  }
}

  dynamic "filesystem" {
    for_each = var.share_filesystem.source != null ? [var.share_filesystem.source] : []
    content {
      source     = var.share_filesystem.source
      target     = var.share_filesystem.target
      readonly   = var.share_filesystem.readonly
      accessmode = var.share_filesystem.mode
    }
  }
  dynamic "graphics" {
    for_each = var.graphics == "none" ? [] : [var.graphics]
    content {
      type        = graphics.value
      listen_type = "address"
      autoport    = true
    }
  }
}
