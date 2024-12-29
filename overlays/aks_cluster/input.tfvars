# The stage (or staging environment) is assigned to be run on a test environment
# (research group) on Airpro azure. 

tenant_name                             = "hallinc"
env                                     = "stage"
subscription_id                         = "a011ea95-c1fe-4125-9cef-82abcac7f740"
tenant_id                               = "375f0d00-5d9c-4f6b-9e6c-1f83fe706392"
location                                = "swedencentral"
project                                 = "test"
aks_vm_size                             = "Standard_B2s"
vnet_cidr                               = "10.52.0.0/16"
allowed_subnet_ids                      = ["10.52.0.0/24"]
allowed_ips                             = ["85.76.151.173/32"]
aks_cidr                                = "10.52.0.0/24"
aks_service_cidr                        = "10.0.0.0/16"
aks_dns_service_ip                      = "10.0.0.10"
aks_docker_cidr                         = "170.10.0.1/16"
ingress_application_gateway_subnet_cidr = "10.52.1.0/24"
private_endpoint_cidr                   = "10.52.2.0/26"