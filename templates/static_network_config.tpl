version: 2
ethernets:
  ${nic}:
    dhcp4: no
    addresses: [${vm_ip_address}]
    gateway4: ${vm_ip_gateway}
    nameservers:
       addresses:
       %{~ for dns_server in vm_dns_servers ~}
       - ${dns_server}
       %{~ endfor ~}
