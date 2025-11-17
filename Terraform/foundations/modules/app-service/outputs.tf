output "app_service_id" {
  description = "ID of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = var.app_service_name
}

output "default_hostname" {
  description = "Default hostname of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].outbound_ip_addresses : azurerm_windows_web_app.this[0].outbound_ip_addresses
}
