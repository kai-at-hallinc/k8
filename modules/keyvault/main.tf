resource "azurerm_key_vault" "keyvault" {

  resource_group_name = var.key_vault_resource_group
  name                = var.key_vault_name
  location            = var.location
  sku_name            = var.key_vault_sku_name
  tenant_id           = var.key_vault_tenant_id

  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_enable_purge_protection

  enable_rbac_authorization = var.key_vault_enable_rbac_authorization

  network_acls {
    default_action             = "Deny"
    bypass                     = var.nacl_allow_azure_services ? "AzureServices" : "None"
    ip_rules                   = var.nacl_allowed_ip_rules
    virtual_network_subnet_ids = var.nacl_allowed_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      access_policy # Access policies are managed using `azurerm_key_vault_access_policy` resources
    ]
  }

}
# Logging
resource "azurerm_monitor_diagnostic_setting" "monitor_kv" {
  log_analytics_workspace_id = var.log_analytics_workspace_id
  name                       = "${var.key_vault_name}_log_analytics"
  target_resource_id         = azurerm_key_vault.keyvault.id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = false

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

# Networking
locals {
  private_endpoint_name                    = var.private_endpoint_name != null ? var.private_endpoint_name : "pe-${var.key_vault_name}"
  private_endpoint_service_connection_name = var.private_endpoint_service_connection_name != null ? var.private_endpoint_service_connection_name : "psc-${var.key_vault_name}"
}

resource "azurerm_private_endpoint" "keyvault" {

  resource_group_name =  var.key_vault_resource_group
  name                = local.private_endpoint_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = local.private_endpoint_service_connection_name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["vault"]
  }
}
