variable "create_resource_group" {
  description = "Flag to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the resources should be created"
  type        = string
}

variable "create_vnet" {
  description = "Flag to create a new virtual network (VNet)"
  type        = bool
  default     = true
}

variable "vnetwork_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR blocks for the virtual network address space"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of DNS server IPs for the VNet"
  type        = list(string)
  default     = []
}

variable "create_subnets" {
  description = "Flag to create subnets in the VNet"
  type        = bool
  default     = true
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name            = string
    address_prefixes = list(string)
  }))
  default = []
}

variable "create_nsg" {
  description = "Flag to create a Network Security Group"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_nat_gateway" {
  description = "Flag to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "create_firewall" {
  description = "Flag to create an Azure Firewall"
  type        = bool
  default     = false
}

variable "enable_ddos" {
  description = "Flag to enable DDoS protection on the VNet"
  type        = bool
  default     = false
}

variable "create_network_watcher" {
  description = "Flag to create a Network Watcher"
  type        = bool
  default     = false
}