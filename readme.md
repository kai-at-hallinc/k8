# infratructure test

## Pre-requisites

Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos)

Infra could be deployed to one of four different environments.  :
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
    *  Add local ip address to the storage account where terraform state is stored.

2. Run Terraform project for oidc_config (storage, RG, UAI) for a the environment.

        cd overlays/oidc
        terraform init
        terraform plan -out=plan.tfplan --var-file=input.tfvars`
        terraform apply --var-file=input.tfvars`

3. Run Terraform project for aks-cluster
    TODO

4. Run Terraform project for app`
    TODO

5. Run Terraform project for database
    TODO



    This deploys K8s namespace, and installs cert-manager and nginx-ingress

6. Deploy ingress resources to cluster

    *   Connect kubectl to created K8s Cluster :
            `az aks get-credentials --resource-group rg-resourceplanning-test-westeu-001 --name ghallocation-dev-aks`
    
    *   Deploying ingress resource and cluster issuer  :
            sh deploy.sh

    *   Inspect nginx-ingress                          :
            kubectl get services -n ghallocation-dev



 ## Creating the Resource Group and Storage account for Azure backend (Only needs to be done once).

The present setup requires that the parent Azure Resource Group and Azure Storage account (for saving Terraform backend) has already been created on Azure Portal.

TODO
