terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.106.1, <= 4.14.0"
    }
  }

  #required_version = ">= 1.1.7"
  backend "azurerm" {
    resource_group_name  = "aks-sandbox-rg"
    storage_account_name = "hallinctfstate"
    container_name       = "tfstate"
    key                  = "core.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
    template_deployment {
      # Ensures that the resources (subnets) created through the deployment are destroyed.
      delete_nested_items_during_deletion = true
    }
  }
  subscription_id = var.subscription_id
  skip_provider_registration = true
}


