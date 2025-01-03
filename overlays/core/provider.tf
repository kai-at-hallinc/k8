terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }

  # other settings are injected from actions pipeline
  backend "azurerm" {
    key      = "core.tfstate"
    use_oidc = true
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  use_oidc                   = true
  skip_provider_registration = true
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


