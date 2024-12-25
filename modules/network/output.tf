output "vnet_id" {
  description = "The VNet ID"
  value       = azurerm_virtual_network.vnet.id
}

output "private_endpoint_subnet_id" {
  description = "Private endpoint subnet id"
  value       = azurerm_subnet.private_endpoint.id
}

output "aks_subnet_id" {
  description = "AKS subnet id"
  value       = azurerm_subnet.aks_subnet.id
}