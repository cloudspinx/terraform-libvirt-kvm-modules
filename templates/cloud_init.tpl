#cloud-config

# Upgrade the instance on first boot
package_update: false
package_upgrade: false

# Host management
preserve_hostname: ${preserve_hostname}
create_hostname_file: ${create_hostname_file}
hostname: ${vm_hostname}
fqdn: ${vm_fqdn}
prefer_fqdn_over_hostname: ${prefer_fqdn_over_hostname}
timezone: ${time_zone}

ssh_pwauth: ${enable_ssh_pwauth}
disable_root: ${disable_root_login}

# Add users to the system
users:
  %{ if not disable_root_login ~}
  - name: root
    lock_passwd: ${lock_root_user_password}
    %{ if enable_root_password and not lock_root_user_password ~}
    chpasswd:
      users:
      - {name: root, password: ${root_password}, type: text}
      expire: False
    %{ endif ~}
    %{ if length(ssh_keys) > 0 ~}
    ssh_authorized_keys:
     %{~ for ssh_key in ssh_keys ~}
     - ${ssh_key}
     %{~ endfor ~}
    %{ endif ~}
  %{ endif ~}
  - name: ${ssh_user_name}
    gecos: ${ssh_user_name}
    lock-passwd: ${lock_user_password}
    sudo: ALL=(ALL) NOPASSWD:ALL
    system: False
    %{ if length(ssh_keys) > 0 }
    ssh_authorized_keys:
     %{~ for ssh_key in ssh_keys ~}
     - ${ssh_key}
     %{~ endfor ~}
    %{ endif }
    shell: ${user.shell}
    %{ if set_ssh_user_password and not lock_user_password ~}
    chpasswd:
      users:
        - {name: ${ssh_user_name}, password: ${ssh_user_password}}
      expire: False
    %{ endif ~}
  %{~ endfor ~}

# Grow root partition to fill the disk
growpart:
    mode: auto
    devices:
      - "/"
resize_rootfs: true

# Install packages
%{ if length(packages) > 0 }
packages:
  %{~ for pkg in packages ~}
  - ${pkg}
  %{~ endfor ~}
%{ endif }

# Command to execute after the first boot (only once)
%{ if length(runcmds) > 0 }
runcmd:
  %{~ for cmd in runcmds ~}
  - ${cmd}
  %{~ endfor ~}
%{ endif }

# Disable IPv6
%{ if disable_ipv6 ~}
write_files:
  - path: /etc/sysctl.d/10-disable-ipv6.conf
    permissions: '0644'
    owner: root:root
    content: |
      net.ipv6.conf.all.disable_ipv6 = 1
      net.ipv6.conf.default.disable_ipv6 = 1
%{ endif ~}