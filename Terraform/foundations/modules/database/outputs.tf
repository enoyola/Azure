output "server_fqdn" {
  description = "FQDN of the database server"
  value = var.database_type == "sql" ? azurerm_mssql_server.this[0].fully_qualified_domain_name : (
    var.database_type == "mysql" ? azurerm_mysql_flexible_server.this[0].fqdn : (
      var.database_type == "postgresql" ? azurerm_postgresql_flexible_server.this[0].fqdn : null
    )
  )
}

output "database_name" {
  description = "Name of the database"
  value       = var.database_name
}

output "admin_username" {
  description = "Admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Admin password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "connection_string" {
  description = "Database connection string"
  value = var.database_type == "sql" ? "Server=tcp:${azurerm_mssql_server.this[0].fully_qualified_domain_name},1433;Database=${var.database_name};User ID=${var.admin_username};Password=${random_password.db_password.result};Encrypt=true;" : (
    var.database_type == "mysql" ? "Server=${azurerm_mysql_flexible_server.this[0].fqdn};Database=${var.database_name};Uid=${var.admin_username};Pwd=${random_password.db_password.result};" : (
      var.database_type == "postgresql" ? "Host=${azurerm_postgresql_flexible_server.this[0].fqdn};Database=${var.database_name};Username=${var.admin_username};Password=${random_password.db_password.result}" : null
    )
  )
  sensitive = true
}
