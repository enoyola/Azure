output "bastion_id" {
  description = "ID of the Azure Bastion"
  value       = azurerm_bastion_host.bastion.id
}

output "bastion_name" {
  description = "Name of the Azure Bastion"
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "DNS name of the Bastion"
  value       = azurerm_bastion_host.bastion.dns_name
}

output "public_ip_address" {
  description = "Public IP address of the Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}
