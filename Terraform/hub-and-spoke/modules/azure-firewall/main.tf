resource "azurerm_public_ip" "firewall" {
  name                = "${var.firewall_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# Default Network Rules
resource "azurerm_firewall_network_rule_collection" "default" {
  name                = "DefaultNetworkRules"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowDNS"
    source_addresses      = ["*"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }

  rule {
    name                  = "AllowNTP"
    source_addresses      = ["*"]
    destination_ports     = ["123"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

# Default Application Rules
resource "azurerm_firewall_application_rule_collection" "default" {
  name                = "DefaultApplicationRules"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "AllowWindowsUpdate"
    source_addresses = ["*"]
    
    target_fqdns = [
      "*.windowsupdate.microsoft.com",
      "*.update.microsoft.com",
      "*.windowsupdate.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name             = "AllowAzureServices"
    source_addresses = ["*"]
    
    target_fqdns = [
      "*.azure.com",
      "*.microsoft.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
