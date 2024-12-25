<#
.SYNOPSIS
This script is used to manage and configure Azure Kubernetes Service (AKS) and Application Gateway (AGW) resources.

.DESCRIPTION
This PowerShell script automates the deployment, configuration, and management of Azure Kubernetes Service (AKS) clusters and Application Gateway (AGW) resources. It includes functions to create, update, and delete AKS clusters, as well as to configure AGW settings for traffic routing and load balancing. The script ensures that the AKS and AGW resources are properly integrated and optimized for performance and security.

.NOTES
Author: Kai Hall
Date: 21.12.2024
Version: 1.0

This script requires Azure PowerShell module to be installed and authenticated. Login with az login prior running the script.

.LINK
https://docs.microsoft.com/en-us/azure/aks/
https://docs.microsoft.com/en-us/azure/application-gateway/
#>

#--------------------------------------------------------------------------------------------------------------------#

# set az account 
$ACCOUNT_ID = (az account show --query name --output tsv)
az account set --subscription $ACCOUNT_ID

# variables for the cluster
$AKS_NAME = "aks-agw"
$RESOURCE_GROUP = (az group list --query [1].name --output tsv)
$LOCATION = (az group list --query [1].location --output tsv)
$VM_SIZE = "Standard_B2s"

# create the cluster
az aks create `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_NAME `
    --location $LOCATION `
    --node-vm-size $VM_SIZE `
    --network-plugin azure `
    --enable-oidc-issuer `
    --enable-workload-identity `
    --generate-ssh-key

#--------------------------------------------------------------------------------------------------------------------#

# create agw and it's networking resources

$APPGW_NAME = "aks-application-gateway"
$APPGW_SUBNET_NAME="appgw-subnet"

# find aks mng rg
$NODE_RESOURCE_GROUP = (az aks show `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_NAME `
    --query nodeResourceGroup `
    --output tsv
)
# find aks vnet name
$AKS_VNET_NAME = (az network vnet list `
    --resource-group $NODE_RESOURCE_GROUP `
    --query [0].name `
    --output tsv
)

# create aks subnet
az network vnet subnet create `
    --resource-group $NODE_RESOURCE_GROUP  `
    --vnet-name $AKS_VNET_NAME `
    --name $APPGW_SUBNET_NAME `
    --address-prefixes "10.226.0.0/23"

# find aks subnet id
$APPGW_SUBNET_ID = (az network vnet subnet list `
    --resource-group $NODE_RESOURCE_GROUP `
    --vnet-name $AKS_VNET_NAME `
    --query "[?name=='$APPGW_SUBNET_NAME'].id" `
    --output tsv
)

# create appgw-ip
$AGW_IP_NAME = "appgw-ip"
az network public-ip create `
    --resource-group $RESOURCE_GROUP `
    --name $AGW_IP_NAME `
    --sku Standard `
    --location $LOCATION

# create agw
az network application-gateway create `
  --name $APPGW_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --subnet $APPGW_SUBNET_ID `
  --capacity 1 `
  --sku Standard_v2 `
  --http-settings-cookie-based-affinity Disabled `
  --frontend-port 80 `
  --http-settings-port 80 `
  --http-settings-protocol Http `
  --public-ip-address $AGW_IP_NAME `
  --priority 10

# get agw id for agic install
$APPGW_ID = (az network application-gateway show `
    --name $APPGW_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "id" `
    --output tsv
)
#--------------------------------------------------------------------------------------------------------------------#

# create managed identity for agw

$IDENTITY_RESOURCE_NAME='agic-identity'
Write-Output "Creating identity $IDENTITY_RESOURCE_NAME in resource group $RESOURCE_GROUP"

az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY_RESOURCE_NAME
$IDENTITY_PRINCIPAL_ID = (az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -o tsv)
$IDENTITY_CLIENT_ID = (az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query clientId -o tsv)

Write-Output "Waiting 60 seconds to allow for replication of the identity..."
Start-Sleep -Seconds 60

Write-Output "Set up federation with AKS OIDC issuer"

$AKS_OIDC_ISSUER = (az aks show -n $AKS_NAME -g $RESOURCE_GROUP --query "oidcIssuerProfile.issuerUrl" -o tsv)

# Create a federated credential for the managed identity to allow it to access the AKS cluster
az identity federated-credential create `
    --name "agic" `
    --identity-name $IDENTITY_RESOURCE_NAME `
    --resource-group $RESOURCE_GROUP `
    --issuer $AKS_OIDC_ISSUER `
    --subject "system:serviceaccount:default:ingress-azure"

$RESOURCE_GROUP_ID = (az group show --name $RESOURCE_GROUP --query id -o tsv)
$NODE_RESOURCE_GROUP_ID = (az group show --name $NODE_RESOURCE_GROUP --query id -o tsv)

# assign roles for the identity

Write-Output "Apply role assignments to AGIC identity"

az role assignment create `
    --assignee-object-id $IDENTITY_PRINCIPAL_ID `
    --assignee-principal-type ServicePrincipal `
    --scope $RESOURCE_GROUP_ID --role "Reader"

az role assignment create `
    --assignee-object-id $IDENTITY_PRINCIPAL_ID `
    --assignee-principal-type ServicePrincipal `
    --scope $NODE_RESOURCE_GROUP_ID `
    --role "Contributor"

az role assignment create `
    --assignee-object-id $IDENTITY_PRINCIPAL_ID `
    --assignee-principal-type ServicePrincipal `
    --scope $APPGW_ID `
    --role "Contributor"

#--------------------------------------------------------------------------------------------------------------------#
# install agic with helm

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

helm install ingress-azure `
  oci://mcr.microsoft.com/azure-application-gateway/charts/ingress-azure `
  --set appgw.applicationGatewayID=$APPGW_ID `
  --set armAuth.type=workloadIdentity `
  --set armAuth.identityClientID=$IDENTITY_CLIENT_ID `
  --set rbac.enabled=true `
  --version 1.7.3