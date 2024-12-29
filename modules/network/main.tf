# create vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group
  address_space       = [var.vnet_cidr]  
}

# create private endpoint subnet with services
resource "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.private_endpoint_cidr]

  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = false
  
  service_endpoints                              = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
  depends_on = [azurerm_virtual_network.vnet]
}

# create cluster subnet with service endpoints
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.aks_cidr]

  enforce_private_link_endpoint_network_policies = true

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]

  depends_on = [azurerm_virtual_network.vnet]
}
