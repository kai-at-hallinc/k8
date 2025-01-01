# K8's Infrastructure POC

This readme contains instruction on how to deploy the ghallocation infrastructure using terraform.
Individual appllications are deployd from their respective repos.

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

1. Set Azure context by:
    *  Logging to Azure CLI     : `az login`
    *  Set the subscription ID  : `az account set --subscription="id"`
    
2. Run Terraform project for oidc_config (storage, RG, UAI) by:
    * Navigate to folder        : `cd overlays/oidc_config`
    * Initialize terraform      : `terraform init`
    * Lint the terraform code   : `terraform fmt`
    * Validate the structure    : `terraform validate`
    * Apply the terraform       : `terraform apply --var-file=input.tfvars`

    *note: This is a preliminary step and independent structure. All the needed files are deployed from
    'oidc_config' folder. Az credentials are used for this deployment.*

3. Setup Github secrets and environment for github actions pipelines by:
    * AZURE_CLIENT_ID (UMI clientId)
    * AZURE_SUBSCRIPTION_ID
    * AZURE_TENANT_ID
    * AZURE_RESOURCE_GROUP_NAME
    * BACKEND_AZURE_STORAGE_ACCOUNT_NAME
    * BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME
    * ENV: stage

    *note: Secrets are to be set as environment secrets inside the stage environment*

4. Run Terraform project for aks-cluster by:
    * Run deploy_cluster_oidc pipeline from .github/workflow folder
    * check that tests defined for pipeline pass
    
    Pipeline will deploy all the modules using main.tf file in overlays/aks_cluster folder.
    Modules containing the resources are in modules folder.

5. Run Terraform project for app by:
    * run deploy_app_oidc pipeline from .github/workflows folder. Pipeline files are in overlays/app folder.
    
    *note: This deploys K8s namespace, role assingments and installs cert-manager and nginx-ingress*
    
6. Run Terraform project for database
    When deploying to stage or prod environment with live data, this might not be needed. There is no database migration
    defined at the moment. Before deploying make sure to prevent data loss!

7. Deploy ingress resources to cluster by:
    *   Connect kubectl to created K8s Cluster :
            `az aks get-credentials --resource-group rg-resourceplanning-test-westeu-001 --name ghallocation-dev-aks`
    *   Deploy ingress resource and cluster issuer by running below file on bash :
            sh deploy.sh
    *   Inspect nginx-ingress                          :
            kubectl get services -n ghallocation-dev
    
    *note: Helm is needed since nginx and cert manager are installed through helm release*

Most pipelines contain or will contain tests. These are simple infrastrcture tests written in bash.
Pipelines will revert back to previous desire d state if tests are not succesfull (TODO).

Deployed resource can be destroyed by:
    * navigate to folder containing the main.tf
    * get storage account access key /SAS
    * install access key as env variable:
         $env:ARM_ACCESS_KEY=<storage account access key>
    * run terraform init
    * run terraform destroy
    * release lock if needed: terraform force-unlock <lockId>
    * provide resource group

    *note: provide the terraform with needed variables and fix possible errors!*