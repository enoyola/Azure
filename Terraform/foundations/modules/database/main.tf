resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Azure SQL Database
resource "azurerm_mssql_server" "this" {
  count = var.database_type == "sql" ? 1 : 0

  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = random_password.db_password.result
  minimum_tls_version          = "1.2"

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  count = var.database_type == "sql" ? 1 : 0

  name      = var.database_name
  server_id = azurerm_mssql_server.this[0].id
  sku_name  = var.sql_sku_name

  tags = var.tags
}

# Azure MySQL
resource "azurerm_mysql_flexible_server" "this" {
  count = var.database_type == "mysql" ? 1 : 0

  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = random_password.db_password.result
  sku_name               = var.mysql_sku_name
  version                = "8.0.21"

  storage {
    size_gb = 20
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "this" {
  count = var.database_type == "mysql" ? 1 : 0

  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this[0].name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Azure PostgreSQL
resource "azurerm_postgresql_flexible_server" "this" {
  count = var.database_type == "postgresql" ? 1 : 0

  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = random_password.db_password.result
  sku_name               = var.postgresql_sku_name
  version                = "14"
  storage_mb             = 32768

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  count = var.database_type == "postgresql" ? 1 : 0

  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
