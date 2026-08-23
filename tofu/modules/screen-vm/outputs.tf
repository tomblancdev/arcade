output "vmid" {
  value = proxmox_virtual_environment_vm.screen.vm_id
}
output "mac_address" {
  description = "the NIC's MAC (read back — a lab writes it to its facts)"
  value       = try(proxmox_virtual_environment_vm.screen.network_device[0].mac_address, null)
}
