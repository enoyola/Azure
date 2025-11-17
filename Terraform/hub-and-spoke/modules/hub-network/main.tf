resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_network_security_group" "nsg" {
  for_each = { for k, v in var.subnets : k => v if v.nsg_required }

  name                = "${var.vnet_name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = { for k, v in var.subnets : k => v if v.nsg_required }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# Bastion NSG Rules
resource "azurerm_network_security_rule" "bastion_inbound_https" {
  count = contains(keys(var.subnets), "AzureBastionSubnet") ? 1 : 0

  name                        = "AllowHttpsInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["AzureBastionSubnet"].name
}

resource "azurerm_network_security_rule" "bastion_inbound_gateway" {
  count = contains(keys(var.subnets), "AzureBastionSubnet") ? 1 : 0

  name                        = "AllowGatewayManagerInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["AzureBastionSubnet"].name
}

resource "azurerm_network_security_rule" "bastion_outbound_ssh_rdp" {
  count = contains(keys(var.subnets), "AzureBastionSubnet") ? 1 : 0

  name                        = "AllowSshRdpOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["AzureBastionSubnet"].name
}

resource "azurerm_network_security_rule" "bastion_outbound_azure_cloud" {
  count = contains(keys(var.subnets), "AzureBastionSubnet") ? 1 : 0

  name                        = "AllowAzureCloudOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["AzureBastionSubnet"].name
}
