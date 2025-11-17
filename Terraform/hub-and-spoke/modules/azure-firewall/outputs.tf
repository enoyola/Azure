output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.firewall.id
}

output "firewall_name" {
  description = "Name of the Azure Firewall"
  value       = azurerm_firewall.firewall.name
}

output "private_ip_address" {
  description = "Private IP address of the firewall"
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the firewall"
  value       = azurerm_public_ip.firewall.ip_address
}
