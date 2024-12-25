output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.keyvault.id
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.keyvault.name
}

output "key_vault_url" {
  description = "URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.keyvault.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vaults private endpoint."
  value       = azurerm_private_endpoint.keyvault.id
}

output "private_endpoint_ip_address" {
  description = "Private IP address of Key Vault instance"
  value       = azurerm_private_endpoint.keyvault.custom_dns_configs[0].ip_addresses[0]
}

output "private_endpoint_fqdn" {
  description = "Fully qualified domain name (FQDN) of Key Vault instance"
  value       = azurerm_private_endpoint.keyvault.custom_dns_configs[0].fqdn
}