locals {
  create_vnet            = var.create_vnet
  create_subnets         = local.create_vnet && var.create_subnets
  create_nsg             = local.create_vnet && var.create_nsg
  create_nat_gateway     = local.create_vnet && var.create_nat_gateway
  create_firewall        = local.create_vnet && var.create_firewall
  create_network_watcher = var.create_network_watcher
  location               = var.location
}

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags)
}

resource "azurerm_virtual_network" "vnet" {
  count               = local.create_vnet ? 1 : 0
  name                = var.vnetwork_name
  location            = var.location
  resource_group_name = local.create_vnet ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rgrp[0].name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = merge({ "Name" = format("%s", var.vnetwork_name) }, var.tags)

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos ? [1] : []

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }
}

resource "azurerm_subnet" "subnet" {
  count                = local.create_subnets ? length(var.subnets) : 0
  name                 = var.subnets[count.index].name
  resource_group_name  = local.create_vnet ? azurerm_virtual_network.vnet[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = var.subnets[count.index].address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  count               = local.create_nsg ? 1 : 0
  name                = "example-nsg"
  location            = var.location
  resource_group_name = local.create_vnet ? azurerm_virtual_network.vnet[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  tags                = var.tags

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = local.create_nsg ? { for idx, subnet in var.subnets : idx => subnet } : {}

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

resource "azurerm_nat_gateway" "nat_gateway" {
  count               = local.create_nat_gateway ? 1 : 0
  name                = "example-nat-gateway"
  location            = var.location
  resource_group_name = local.create_vnet ? azurerm_virtual_network.vnet[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "nat_public_ip" {
  count               = local.create_nat_gateway ? 1 : 0
  name                = "nat-public-ip"
  location            = var.location
  resource_group_name = local.create_vnet ? azurerm_virtual_network.vnet[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_association" {
  for_each = { for idx, subnet in var.subnets : idx => subnet }

  subnet_id      = azurerm_subnet.subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway[0].id
}

resource "azurerm_firewall" "firewall" {
  count               = local.create_firewall ? 1 : 0
  name                = "example-firewall"
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rgrp[0].name
  sku_name            = "AZFW_Hub" # This could be "AZFW_VNet" if you are using a VNet SKU.
  sku_tier            = "Standard" # Set to "Standard" or "Premium" depending on your needs
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet[0].id
    public_ip_address_id = azurerm_public_ip.firewall_ip[0].id
  }
}

resource "azurerm_public_ip" "firewall_ip" {
  count               = local.create_firewall ? 1 : 0
  name                = "firewall-ip"
  location            = var.location
  resource_group_name = local.create_vnet ? azurerm_virtual_network.vnet[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  count                = local.create_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[0].id
  public_ip_address_id = azurerm_public_ip.nat_public_ip[0].id
}

#networkWatcher if you need to monitor network traffic and diagnose issues.
resource "azurerm_resource_group" "nwatcher" {
  count    = local.create_network_watcher ? 1 : 0
  name     = "NetworkWatcherRG"
  location = local.location
  tags     = merge({ "Name" = "NetworkWatcherRG" }, var.tags)
}

resource "azurerm_network_watcher" "nwatcher" {
  count               = local.create_network_watcher ? 1 : 0
  name                = "NetworkWatcher_${local.location}"
  location            = local.location
  resource_group_name = azurerm_resource_group.nwatcher[0].name
  tags                = merge({ "Name" = format("%s", "NetworkWatcher_${local.location}") }, var.tags)
}