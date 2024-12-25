locals {
  allowed_virtual_networks = [
  for s in var.allowed_subnet_ids : {
    action    = "Allow",
    subnet_id = s
  }
  ]

  allowed_ips = [
  for s in var.allowed_ips : {
    action   = "Allow",
    ip_range = s
  }
  ]
}

resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.container_registry_resource_group
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
  network_rule_set {
    default_action  = "Allow"
    virtual_network = local.allowed_virtual_networks
    ip_rule         = local.allowed_ips
  }
}