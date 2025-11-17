variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "server_name" {
  description = "Name of the database server"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "database_type" {
  description = "Type of database (sql, mysql, postgresql)"
  type        = string
  default     = "sql"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
}

variable "sql_sku_name" {
  description = "SKU name for Azure SQL Database"
  type        = string
  default     = "Basic"
}

variable "mysql_sku_name" {
  description = "SKU name for MySQL"
  type        = string
  default     = "B_Standard_B1s"
}

variable "postgresql_sku_name" {
  description = "SKU name for PostgreSQL"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
