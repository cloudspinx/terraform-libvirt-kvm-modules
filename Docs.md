<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.8.3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |
| <a name="requirement_template"></a> [template](#requirement\_template) | 2.2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.8.3 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ./modules/libvirt-network | n/a |
| <a name="module_os_image"></a> [os\_image](#module\_os\_image) | ./modules/os-images | n/a |
| <a name="module_storage_pool"></a> [storage\_pool](#module\_storage\_pool) | ./modules/storage-pool | n/a |

## Resources

| Name | Type |
|------|------|
| [libvirt_cloudinit_disk.commoninit](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.3/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.this_domain](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.3/docs/resources/domain) | resource |
| [libvirt_volume.additional_disk](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.3/docs/resources/volume) | resource |
| [libvirt_volume.base_image](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.3/docs/resources/volume) | resource |
| [libvirt_volume.vm_disk_qcow2](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.3/docs/resources/volume) | resource |
| [local_sensitive_file.root_password](https://registry.terraform.io/providers/hashicorp/local/2.5.2/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/2.5.2/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/2.5.2/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.user_password](https://registry.terraform.io/providers/hashicorp/local/2.5.2/docs/resources/sensitive_file) | resource |
| [random_id.uuid](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/id) | resource |
| [random_password.root_password](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [random_password.user_password](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.6/docs/resources/private_key) | resource |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/cloudinit_config) | data source |
| [template_cloudinit_config.network](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_disk_count"></a> [additional\_disk\_count](#input\_additional\_disk\_count) | Number of additional disks to attach | `number` | `0` | no |
| <a name="input_additional_disk_ids"></a> [additional\_disk\_ids](#input\_additional\_disk\_ids) | List of volume ids | `list(string)` | `[]` | no |
| <a name="input_additional_disk_size"></a> [additional\_disk\_size](#input\_additional\_disk\_size) | Additional disk size (in GB) | `number` | `0` | no |
| <a name="input_base_volume_name"></a> [base\_volume\_name](#input\_base\_volume\_name) | Name of base OS image | `string` | `null` | no |
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host) | The bastion host to use for SSH connection | `string` | `""` | no |
| <a name="input_bastion_private_key"></a> [bastion\_private\_key](#input\_bastion\_private\_key) | The private key to use for SSH connection to the bastion host | `string` | `""` | no |
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user) | The user to use for SSH connection to the bastion host | `string` | `""` | no |
| <a name="input_cpu_mode"></a> [cpu\_mode](#input\_cpu\_mode) | The CPU mode for the instance | `string` | `"host-passthrough"` | no |
| <a name="input_create_additional_disk"></a> [create\_additional\_disk](#input\_create\_additional\_disk) | Whether to create additional disks | `bool` | `false` | no |
| <a name="input_create_hostname_file"></a> [create\_hostname\_file](#input\_create\_hostname\_file) | Create a hostname file for the instance | `bool` | `true` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | Whether to create the libvirt network | `bool` | `false` | no |
| <a name="input_create_storage_pool"></a> [create\_storage\_pool](#input\_create\_storage\_pool) | Whether to create the storage Libvirt storage pool | `bool` | `false` | no |
| <a name="input_custom_image_path_url"></a> [custom\_image\_path\_url](#input\_custom\_image\_path\_url) | Path to locally cached image or remote URL | `string` | `""` | no |
| <a name="input_disable_ipv6"></a> [disable\_ipv6](#input\_disable\_ipv6) | Disable IPv6 on the instance | `bool` | `false` | no |
| <a name="input_disable_root_login"></a> [disable\_root\_login](#input\_disable\_root\_login) | Disable root user login | `bool` | `true` | no |
| <a name="input_enable_ssh_pwauth"></a> [enable\_ssh\_pwauth](#input\_enable\_ssh\_pwauth) | Enable ssh password login | `bool` | `false` | no |
| <a name="input_generate_ssh_keys"></a> [generate\_ssh\_keys](#input\_generate\_ssh\_keys) | Generate SSH keys for the instance | `bool` | `true` | no |
| <a name="input_graphics"></a> [graphics](#input\_graphics) | Graphics type for instance installation | `string` | `"none"` | no |
| <a name="input_index_start"></a> [index\_start](#input\_index\_start) | The starting index for the VMs | `number` | `1` | no |
| <a name="input_lock_root_user_password"></a> [lock\_root\_user\_password](#input\_lock\_root\_user\_password) | Lock root user password | `bool` | `true` | no |
| <a name="input_lock_user_password"></a> [lock\_user\_password](#input\_lock\_user\_password) | Lock root user password | `bool` | `false` | no |
| <a name="input_manage_etc_hosts"></a> [manage\_etc\_hosts](#input\_manage\_etc\_hosts) | Manage the /etc/hosts file | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory for the instance (in MB) | `string` | `"1024"` | no |
| <a name="input_network_autostart"></a> [network\_autostart](#input\_network\_autostart) | Whether the network should autostart | `bool` | `true` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | The bridge device for the network | `string` | `"virbr10"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | List of CIDR addresses for the network | `list(string)` | <pre>[<br/>  "172.21.0.0/24"<br/>]</pre> | no |
| <a name="input_network_dhcp_enabled"></a> [network\_dhcp\_enabled](#input\_network\_dhcp\_enabled) | Whether DHCP is enabled for the network | `bool` | `true` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | The network interface for the instance | `string` | `"ens3"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The network mode (e.g., nat, bridge) | `string` | `"nat"` | no |
| <a name="input_network_mtu"></a> [network\_mtu](#input\_network\_mtu) | The MTU for the network | `number` | `1500` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the libvirt network | `string` | `"default"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | OS disk size (in GB) | `number` | `"10"` | no |
| <a name="input_os_name"></a> [os\_name](#input\_os\_name) | The name of the os to use | `string` | `"ubuntu"` | no |
| <a name="input_os_version"></a> [os\_version](#input\_os\_version) | The version of the os to use | `string` | `"latest"` | no |
| <a name="input_package_update"></a> [package\_update](#input\_package\_update) | Update the package list | `bool` | `true` | no |
| <a name="input_packages"></a> [packages](#input\_packages) | Extra packages to install on the instance | `list(string)` | <pre>[<br/>  "qemu-guest-agent",<br/>  "vim",<br/>  "wget",<br/>  "curl",<br/>  "unzip",<br/>  "git"<br/>]</pre> | no |
| <a name="input_prefer_fqdn_over_hostname"></a> [prefer\_fqdn\_over\_hostname](#input\_prefer\_fqdn\_over\_hostname) | Prefer FQDN over hostname | `bool` | `true` | no |
| <a name="input_preserve_hostname"></a> [preserve\_hostname](#input\_preserve\_hostname) | Preserve the hostname of the instance | `bool` | `false` | no |
| <a name="input_runcmds"></a> [runcmds](#input\_runcmds) | Extra commands to be run with cloud init | `list(string)` | <pre>[<br/>  "[ systemctl, daemon-reload ]",<br/>  "[ systemctl, enable, qemu-guest-agent ]",<br/>  "[ systemctl, start, qemu-guest-agent ]",<br/>  "[ systemctl, restart, systemd-networkd ]"<br/>]</pre> | no |
| <a name="input_set_root_password"></a> [set\_root\_password](#input\_set\_root\_password) | Enable setting a root password | `bool` | `false` | no |
| <a name="input_set_ssh_user_password"></a> [set\_ssh\_user\_password](#input\_set\_ssh\_user\_password) | Enable setting a user password | `bool` | `false` | no |
| <a name="input_set_user_password"></a> [set\_user\_password](#input\_set\_user\_password) | Enable setting a root password | `bool` | `false` | no |
| <a name="input_share_filesystem"></a> [share\_filesystem](#input\_share\_filesystem) | n/a | <pre>object({<br/>    source   = string<br/>    target   = string<br/>    readonly = bool<br/>    mode     = string<br/>  })</pre> | <pre>{<br/>  "mode": null,<br/>  "readonly": false,<br/>  "source": null,<br/>  "target": null<br/>}</pre> | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | List of public ssh keys to add to the instance | `list(string)` | `[]` | no |
| <a name="input_ssh_user_fullname"></a> [ssh\_user\_fullname](#input\_ssh\_user\_fullname) | The full name of the admin user on the target instance | `string` | `"Cloud Admin"` | no |
| <a name="input_ssh_user_name"></a> [ssh\_user\_name](#input\_ssh\_user\_name) | The admin user name to created on the target instance | `string` | `"cloud"` | no |
| <a name="input_ssh_user_shell"></a> [ssh\_user\_shell](#input\_ssh\_user\_shell) | The shell for the admin user on the target instance | `string` | `"/bin/bash"` | no |
| <a name="input_storage_pool_name"></a> [storage\_pool\_name](#input\_storage\_pool\_name) | The name of the storage Libvirt pool | `string` | `"vms_storage"` | no |
| <a name="input_storage_pool_path"></a> [storage\_pool\_path](#input\_storage\_pool\_path) | The path where the storage Libvirt pool will be stored | `string` | `"/var/lib/libvirt/images"` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time Zone | `string` | `"UTC"` | no |
| <a name="input_use_dhcp"></a> [use\_dhcp](#input\_use\_dhcp) | Whether to use DHCP or Static IP for the instance | `bool` | `true` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | The number of vCPUs for the instance | `number` | `1` | no |
| <a name="input_vm_autostart"></a> [vm\_autostart](#input\_vm\_autostart) | Whether the instance should start automatically | `bool` | `true` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | The number of VMs to create | `number` | `1` | no |
| <a name="input_vm_dns_servers"></a> [vm\_dns\_servers](#input\_vm\_dns\_servers) | List of DNS servers | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "1.1.1.1"<br/>]</pre> | no |
| <a name="input_vm_domain"></a> [vm\_domain](#input\_vm\_domain) | The VM's domain that forms the FQDN. | `string` | `"example.com"` | no |
| <a name="input_vm_hostname_prefix"></a> [vm\_hostname\_prefix](#input\_vm\_hostname\_prefix) | The prefix for the VM name | `string` | `"vm"` | no |
| <a name="input_vm_ip_address"></a> [vm\_ip\_address](#input\_vm\_ip\_address) | List of IP addresses for the instance | `list(string)` | `[]` | no |
| <a name="input_vm_ip_gateway"></a> [vm\_ip\_gateway](#input\_vm\_ip\_gateway) | The IP address of the gateway | `string` | `"192.168.122.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_vm_ips"></a> [all\_vm\_ips](#output\_all\_vm\_ips) | n/a |
| <a name="output_root_password"></a> [root\_password](#output\_root\_password) | n/a |
| <a name="output_ssh_commands"></a> [ssh\_commands](#output\_ssh\_commands) | n/a |
| <a name="output_ssh_user_name"></a> [ssh\_user\_name](#output\_ssh\_user\_name) | n/a |
| <a name="output_user_password"></a> [user\_password](#output\_user\_password) | n/a |
<!-- END_TF_DOCS -->