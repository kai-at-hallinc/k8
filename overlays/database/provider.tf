terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version ="3.27.0"
    }
  }

  #required_version = ">= 1.1.7"
  backend "azurerm" {
    resource_group_name  = "rg-resourceplanning-test-westeu-001"
    storage_account_name = "ghallocationtfstatetest"
    container_name       = "ghallocation-tfstate"
    key                  = "ghallocation_database.tfstate"
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

  skip_provider_registration = true
}


