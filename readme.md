# K8's Infrastructure POC

## Pre-requisites

Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos)

Infra can be deployed to:
* `stage`   : Staging environment in tenant

## Setting up resources on Azure with Terraform (Manually with Azure CLI)

The infrastructure requires Azure resource group and storage account for saving terraform backend.

There are four terraform projects for the environment. They are as follows:
* `oidc_config` : Deploys storage account, resource group and identity for github
* `core` : Deploys core infra such as networks and other Azure services (KeyVault, ACR)
* `aks_cluster`: Deploys AKS Cluster [requires core to be already deployed]
* `app`: kubernetes namespace, nginx-ingress and certificate managers.
* `database`: Deploys postgresql database [requires core to be already deployed]

1. Set Azure context by

    *  Logging to Azure CLI     : `az login`
    *  Set the subscription ID  : `az account set --subscription="id"`
    
2. Run Terraform project for oidc_config (storage, RG, UAI) by

    * Navigate to folder        : `cd overlays/oidc_config`
    * Initialize terraform      : `terraform init`
    * Lint the terraform code   : `terraform fmt`
    * Validate the structure    : `terraform validate`
    * Apply the terraform       : `terraform apply --var-file=input.tfvars`

    *note: This is a preliminary step and independent structure. All the needed files are in the
    'oidc_config' folder for simplicity. Az credentials are used for this deployment.*

3. Setup Github secrets and environment for infrastructure pipelines
    * AZURE_CLIENT_ID (UMI clientId)
    * AZURE_SUBSCRIPTION_ID
    * AZURE_TENANT_ID
    * AZURE_RESOURCE_GROUP_NAME
    * BACKEND_AZURE_STORAGE_ACCOUNT_NAME
    * BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME
    * ENV: stage

    *note: Secrets are to be set as environment secrets inside the stage environment*

4. Run Terraform project for aks-cluster
    TODO

5. Run Terraform project for app`
    This deploys K8s namespace, and installs cert-manager and nginx-ingress
    TODO

6. Run Terraform project for database
    TODO


7. Deploy ingress resources to cluster

    *   Connect kubectl to created K8s Cluster :
            `az aks get-credentials --resource-group rg-resourceplanning-test-westeu-001 --name ghallocation-dev-aks`
    
    *   Deploying ingress resource and cluster issuer  :
            sh deploy.sh

    *   Inspect nginx-ingress                          :
            kubectl get services -n ghallocation-dev