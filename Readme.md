## Terraform Azure VNet Module

This Terraform module creates a Virtual Network (VNet) environment in Azure. It includes various network components such as subnets, network security groups (NSGs), NAT gateways, and more, providing a flexible and customizable network setup.

Features:
- VNet: Creates a virtual network with a specified address space.
- Subnets: Creates multiple subnets within the VNet. 
- work Security Groups (NSGs): Optional security groups for controlling traffic to and from resources. 
- Gateway: Provides internet access to resources in the private subnets. 
- Public IP: Associates a static IP address with the NAT Gateway. 
- Route Tables and Associations: Manages routing within the VNet and to/from the internet. 
- DDOS Protection: Optional DDoS protection for the VNet.

This module structure and configuration allow users to create a VNet with customizable settings, including location, subnets, and security configurations. The use of variables makes the module flexible and reusable across different projects and environments. Users can provide their specific values for the variables in a terraform.tfvars file or through other methods, ensuring the infrastructure meets their specific needs.
```sh
terraform-azure-vnet/
├── main.tf          # Core resource definitions
├── variables.tf     # Input variable definitions
├── outputs.tf       # Output definitions
└── terraform.tfvars # (Optional) Default variable values  
```

**main.tf**
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

module "network_infrastructure" {
  source = "achavacloud/vnet/azure"

  for_each = {
    for k, v in var.vnet_configurations : k => v
  }

  create_resource_group = each.value.create_resource_group
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  tags                  = each.value.tags

  create_vnet           = each.value.create_vnet
  vnetwork_name         = each.value.vnetwork_name
  vnet_address_space    = each.value.vnet_address_space
  dns_servers           = each.value.dns_servers

  create_subnets        = each.value.create_subnets
  subnets               = each.value.subnets

  create_nsg            = each.value.create_nsg
  create_nat_gateway    = each.value.create_nat_gateway
  create_firewall       = each.value.create_firewall
  create_network_watcher = each.value.create_network_watcher
  enable_ddos           = each.value.enable_ddos
}
```
**outputs.tf**
```hcl
output "vnet_ids" {
  description = "The IDs of the created Virtual Networks."
  value       = { for key, instance in module.network_infrastructure : key => instance.vnet_id }
}

output "subnet_ids" {
  description = "The IDs of the created subnets."
  value       = { for key, instance in module.network_infrastructure : key => instance.subnet_ids }
}

output "nsg_ids" {
  description = "The IDs of the created Network Security Groups."
  value       = { for key, instance in module.network_infrastructure : key => instance.nsg_id }
}

output "nat_gateway_public_ips" {
  description = "The public IP addresses associated with the NAT Gateways."
  value       = { for key, instance in module.network_infrastructure : key => instance.nat_gateway_public_ip }
}
```
**terraform.tfvars**
```hcl
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""

vnet_configurations = {
  "vnet1_name" = {
    create_resource_group = true/false
    resource_group_name   = "example-rg2"
    location              = "WestUS"
    tags                  = {
      foo = "bar"
      foo = "bar"
    }

    create_vnet           = true/false
    vnetwork_name         = "example-vnet2"
    vnet_address_space    = ["10.1.0.0/16"]
    dns_servers           = ["8.8.8.8", "8.8.4.4"]

    create_subnets        = true/false
    subnets = [
      { name = "subnet1", address_prefixes = ["10.1.1.0/24"] },
      { name = "subnet2", address_prefixes = ["10.1.2.0/24"] }
    ]

    create_nsg            = true/false
    create_nat_gateway    = true/false
    create_firewall       = true/false
    create_network_watcher = true/false
    enable_ddos           = true/false
  }
}
```
**variables.tf**
```hcl
variable "subscription_id" {
  description = "The subscription ID for Azure"
  type        = string
}

variable "client_id" {
  description = "The client ID of the Azure service principal"
  type        = string
}

variable "client_secret" {
  description = "The client secret of the Azure service principal"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for Azure"
  type        = string
}

variable "vnet_configurations" {
  description = "A map of configurations for each VNet and its related resources"
  type = map(object({
    create_resource_group = bool
    resource_group_name   = string
    location              = string
    tags                  = map(string)

    create_vnet           = bool
    vnetwork_name         = string
    vnet_address_space    = list(string)
    dns_servers           = list(string)

    create_subnets        = bool
    subnets               = list(object({
      name             = string
      address_prefixes = list(string)
    }))

    create_nsg            = bool
    create_nat_gateway    = bool
    create_firewall       = bool
    create_network_watcher = bool
    enable_ddos           = bool
  }))
}
```
