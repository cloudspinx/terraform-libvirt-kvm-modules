version: 2
ethernets:
  ${nic}:
    dhcp4: no
    addresses: [${ip_address}]
    gateway4: ${gateway}
    nameservers:
       addresses:
       %{~ for ns in nameservers ~}
       - ${ns}
       %{~ endfor ~}
