$LOCATION= "swedencentral"
$RESOURCE_GROUP= "aks-sandbox-rg"
$CLUSTER_NAME= "aks-nginx-cluster"
$NAMESPACE= "nginx-ingress"
$VM_SIZE= "Standard_B2s"
$NODE_COUNT= 1

# create resource group if does not exist
$resourceGroup = az group show --name $RESOURCE_GROUP --query "name" --output tsv 2>$null # 2>$null omit error message
if (-not $resourceGroup) {
    az group create --name $RESOURCE_GROUP --location $LOCATION
}

# create aks cluster
az aks create `
--resource-group $RESOURCE_GROUP `
--name $CLUSTER_NAME `
--location $LOCATION `
--node-count $NODE_COUNT `
--enable-app-routing `
--generate-ssh-keys `
--node-vm-size $VM_SIZE `
--network-plugin azure `
--enable-oidc-issuer `
--enable-workload-identity 

# update the cluster if needed
az aks update `
--resource-group $RESOURCE_GROUP `
--name $CLUSTER_NAME

# get aks credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# create namespace
kubectl create namespace $NAMESPACE

# apply the backend
kubectl create deployment backend `
--namespace $NAMESPACE `
--image=<image address> `
--replicas=2 `
--port=8081 `
--dry-run=client `
-o yaml > backend.yaml

# apply the frontend
kubectl create deployment frontend `
--namespace $NAMESPACE `
--image=<image address> `
--replicas=2 `
--port=8080 `
--dry-run=client `
-o yaml > frontend.yaml

# apply the deployment manifests
kubectl create -f backend.yaml -n $NAMESPACE --save-config
kubectl create -f frontend.yaml -n $NAMESPACE --save-config

# verify the deployments
kubectl get deploy -o wide -n $NAMESPACE
kubectl get pods -o wide -n $NAMESPACE
kubectl top pod -n $NAMESPACE
kubectl top node

# TODO: inspect ways for tcp in bash

# expose the services
kubectl apply -f .\frontend-svc.yaml -n $NAMESPACE
kubectl apply -f .\backend-svc.yaml -n $NAMESPACE


# install the nginx ingress controller
kubectl apply `
-f 'https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml' `
--namespace=ingress-nginx `
--output yaml > nginx-ingress-controller.yaml

# inspect the controller details
kubectl get all -n ingress-nginx

# Domain name www.hallinc.com resolves to address 9.223.62.117
# this is ingress controller address
# record is kept at azure dns zone

# generate the ingress resource manifest
kubectl create ingress application-ingress `
--rule="hallinc.com/greeting=frontend:80,pathType=Prefix" `
--rule="hallinc.com/k8s=backend:80,pathType=Prefix" `
--dry-run=client `
-o yaml > application-ingress.yaml

# leave host off if dns is not set
# create the ingress resource with kubernetes.io/ingress.class: "nginx" annotation
kubectl apply -f .\application-ingress.yaml

# verify the ingress install
kubectl get ingress -n $NAMESPACE
kubectl describe ingress application-ingress -n $NAMESPACE

# test the ingress
'http://9.223.62.117/k8s/getAllEmployee'
'http://9.223.62.117/k8s/reactiveway'
'http://9.223.62.117/greeting?name=ingress'

# clean up the resources

# delete the both deployments
kubectl delete deployment backend -n $NAMESPACE && `
kubectl delete deployment frontend -n $NAMESPACE
# delete both services
kubectl delete svc backend -n $NAMESPACE && `
kubectl delete svc frontend -n $NAMESPACE
# delete the ingress
kubectl delete ingress application-ingress -n $NAMESPACE
# delete the namespace
kubectl delete namespace $NAMESPACE
# delete the aks cluster
az aks delete --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --yes