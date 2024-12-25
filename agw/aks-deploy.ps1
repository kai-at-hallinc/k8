#--------------------------------------------------------------------------------------------------------------------#
# deployments

# apply all the deployments
kubectl apply -f .\agw\allocation-deploy.yaml
kubectl apply -f .\agw\timetable-deploy.yaml
kubectl apply -f .\agw\optimization-deploy.yaml
kubectl apply -f .\agw\celery-deploy.yaml
kubectl apply -f .\agw\rabbitmg-deploy.yaml

# apply all the services
kubectl apply -f .\agw\allocation-svc.yaml
kubectl apply -f .\agw\timetable-svc.yaml
kubectl apply -f .\agw\optimization-svc.yaml

# apply application ingress
kubectl apply -f .\agw\application-ingress.yaml

# scale down the node pool
az aks scale `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_NAME `
    --nodepool-name $NODEPOOL_NAME `
    --node-count 1
# delete the aks cluster
$RESOURCE_GROUP='aks-sandbox-rg'
$AKS_NAME='aks-agw'

az aks delete --name $AKS_NAME --resource-group $RESOURCE_GROUP --yes