# create the registry
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.container_registry_resource_group
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
  network_rule_set {
    default_action  = "Allow"
    ip_rule         = [
      {
      action        = "Allow"
      ip_range      = var.allowed_ips
      }
    ]
}