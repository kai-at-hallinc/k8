terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }

  # other setting s from actions pipeline
  backend "azurerm" {
    use_oidc = true
    key      = "aks.tfstate"
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  skip_provider_registration = true
  use_oidc                   = true
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
}

provider "tls" {}
data "azurerm_client_config" "current" {}

