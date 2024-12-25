# gh-allocation-infra

## Pre-requisites

Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos)

Infra could be deployed to one of four different environments.  :
* `dev`     : Dev environment in TW Azure tenant
* `test`    : Test environment in TW Azure tenant
* `stage`   : Staging environment in Airpro Azure Tenant
* `prod`    : Production environment in Airpro Azure Tenant


## Setting up resources on Azure with Terraform (Manually with Azure CLI)

This guide assumes that the Azure resource group and storage account for saving terraform backend has already been created.
If not, refer [Creating Resource Group and Storage account](#creating-the-resource-group-and-storage-account-for-azure-backend-only-needs-to-be-done-once)

There are four terraform projects for each environment. They are as follows:
* `core` : Deploys core infra such as networks and other Azure services (KeyVault, ACR)
* `aks_cluster`: Deploys AKS Cluster [requires core to be already deployed]
* `database`: Deploys postgresql database [requires core to be already deployed]
* `app`: kubernetes namespace, nginx-ingress and certificate managers.


1. Set Azure context by

    *  Logging to Azure CLI     : `az login`
    *  Set the subscription ID  : `az account set --subscription="id"`
    *  Add local ip address to the storage account where terraform state is stored.

2. Run Terraform project for core infrastructure (networks, ACR, KV etc) for a particular environment. eg : `dev`

    Define environment variables for Azure Postgresql database admin user and password and run terraform commands.

        cd overlays/dev/core
        terraform init
        terraform plan -out=plan.tfplan --var-file=input.tfvars`
        terraform apply --var-file=input.tfvars`

3. Run Terraform project for aks-cluster for a particular environment. eg : `dev`

    Define environment variables for Azure Postgresql database admin user and password and run terraform commands.

        cd overlays/dev/aks_cluster
        terraform init
        terraform plan -out=plan.tfplan --var-file=input.tfvars`
        terraform apply --var-file=input.tfvars`

4. Run Terraform project for database for a particular environment. eg : `dev`

    Define environment variables for Azure Postgresql database admin user and password and run terraform commands.

        cd overlays/dev/database
        export TF_VAR_db_admin_username=<username> TF_VAR_db_admin_password=<password>
        terraform init
        terraform plan -out=plan.tfplan --var-file=input.tfvars`
        terraform apply --var-file=input.tfvars`

5. Run Terraform project for app for a particular environment. eg : `dev`

        cd overlays/dev/app
        terraform init
        terraform plan --var-file=input.tfvars
        terraform apply --var-file=input.tfvars

    This deploys K8s namespace, and installs cert-manager and nginx-ingress

6. Deploy ingress resources to cluster

    *   Connect kubectl to created K8s Cluster :

            `az aks get-credentials --resource-group rg-resourceplanning-test-westeu-001 --name ghallocation-dev-aks`
    *   Deploying ingress resource and cluster issuer  :

            sh deploy.sh

    *   Inspect nginx-ingress                          :

            kubectl get services -n ghallocation-dev



 ## Creating the Resource Group and Storage account for Azure backend (Only needs to be done once).

The present setup requires that the parent Azure Resource Group and Azure Storage account (for saving Terraform backend) has already been created on Azure Portal. (TODO : Automate Storage account creation). If they have not already been created, follow these instructions.

1.1 Azure Resource Group

    Create Parent resource group in Azure Subscription.

1.2 Storage Accounts

Create an Azure Storage account inside the parent Resource Group. Create a container inside this storage account.
For each terraform project, create a file blob inside the container and name it with value specified in "key".
The names of the Storage Account and containers for an environment should be as specifed in provider.tf file for terraform project.

    resource_group_name  = "rg-resourceplanning-test-westeu-001"
    storage_account_name = "ghallocationtfstatetw"
    container_name       = "ghallocation-tfstate"
    key                  = "ghallocation_infra.tfstate"


