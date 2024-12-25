variable "key_vault_name" {
  description = "Name of the key vault e.g. kv-example"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "Key vault name must comply with regex ^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$."
  }

  validation {
    condition     = 3 <= length(var.key_vault_name) && length(var.key_vault_name) <= 24
    error_message = "Key vault name must be between 3 and 24 characters."
  }
}

variable "key_vault_resource_group" {
  type        = string
  description = "The container registry resourcegroup name."
}

variable "key_vault_tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  type        = string
}

variable "location" {
  description = "Location of the resources to create."
  type        = string

}

variable "key_vault_sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "Allowed values are standard and premium."
  }
}

variable "key_vault_soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 90
}

variable "key_vault_enable_purge_protection" {
  description = "Boolean to enable purge protection. Purge protection prevents you from deleting soft-deleted vaults and objects, and is recommended for production deployments. Defaults to false."
  type        = bool
  default     = false
}

variable "key_vault_enable_rbac_authorization" {
  description = "Boolean to enable rbac authorization on key vault resource. Disabled by default."
  type        = bool
  default     = false
}


# Logging
variable "log_analytics_workspace_id" {
  description = "The resource id of the log analytics workspace e.g. /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.OperationalInsights/workspaces/workspace1"
  type        = string
}

# Networking
variable "private_endpoint_subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into e.g. /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1"
  type        = string
}

variable "private_endpoint_name" {
  description = "(Optional) Name of the private endpoint. Defaults to pe-<key_vault_name>"
  type        = string
  default     = null
}

variable "private_endpoint_service_connection_name" {
  description = "(Optional) Name of the private endpoint service connection. Defaults to psc-<key_vault_name>"
  type        = string
  default     = null
}

variable "nacl_allow_azure_services" {
  description = "Configure Keyvault firewall to bypass the rules and allow Azure services to access. Access is disallowed by default."
  type        = bool
  default     = false
}

variable "nacl_allowed_subnet_ids" {
  description = "(Optional) One or more Subnet resource ID's which should be able to access this Key Vault."
  type        = list(string)
  default     = null
}

variable "nacl_allowed_ip_rules" {
  description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
  type        = list(string)
  default     = null
}
