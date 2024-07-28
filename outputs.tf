output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = local.create_vnet ? azurerm_virtual_network.vnet[0].id : null
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = local.create_subnets ? { for s in azurerm_subnet.subnet : s.name => s.id } : {}
}

output "nsg_id" {
  description = "The ID of the Network Security Group"
  value       = local.create_nsg ? azurerm_network_security_group.nsg[0].id : null
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = local.create_nat_gateway ? azurerm_nat_gateway.nat_gateway[0].id : null
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = local.create_nat_gateway ? azurerm_public_ip.nat_public_ip[0].ip_address : null
}

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = local.create_firewall ? azurerm_firewall.firewall[0].id : null
}

output "network_watcher_id" {
  description = "The ID of the Network Watcher"
  value       = local.create_network_watcher ? azurerm_network_watcher.nwatcher[0].id : null
}