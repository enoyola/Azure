output "vm_id" {
  description = "ID of the virtual machine"
  value       = var.os_type == "linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = var.vm_name
}

output "private_ip_address" {
  description = "Private IP address"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "admin_password" {
  description = "Admin password"
  value       = random_password.admin_password.result
  sensitive   = true
}
