output "gateway_id" {
  description = "ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.gateway.id
}

output "gateway_name" {
  description = "Name of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.gateway.name
}

output "public_ip_address" {
  description = "Public IP address of the gateway"
  value       = azurerm_public_ip.gateway.ip_address
}
