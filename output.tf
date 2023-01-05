output "ip_addr"{
    value = vsphere_virtual_machine.vm.guest_ip_addresses[0]
}

output "mac_addr"{
    value = vsphere_virtual_machine.vm.network_interface[0].mac_address
}