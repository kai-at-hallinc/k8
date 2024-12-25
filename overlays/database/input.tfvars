# The stage (or staging environment) is assigned to be run on a test environment
# (research group) on Airpro azure. 

tenant_name                             = "ap"
env                                     = "stage"
parent_resource_group_name              = "rg-resourceplanning-test-westeu-001"

subscription_id                         = "6bd31116-ebb8-42be-a7f2-712316a57d95"
tenant_id                               = "29d93db2-a75a-476d-abf1-afe5c87dcfff"
location                                = "westeurope"
project                                 = "ghallocation"
aks_vm_size                             = "Standard_D8s_v3"

vnet_cidr                               = "10.52.0.0/16"
allowed_subnet_ids                      = ["10.52.0.0/24"]
allowed_ips                             = ["83.85.221.193/32"]
aks_cidr                                = "10.52.0.0/24"
aks_service_cidr                        = "10.0.0.0/16"
aks_dns_service_ip                      = "10.0.0.10"
aks_docker_cidr                         = "170.10.0.1/16"
ingress_application_gateway_subnet_cidr = "10.52.1.0/24"
private_endpoint_cidr                   = "10.52.2.0/26"
dataplatform_resource_group             = "rg-dataplatform-v25-staging-weu-001"
dataplatform_postgresql_name            = "airpro-dp-postgres-staging"
dataplatform_postgresql_private_endpoint_name = "dataplatform-pg-private-endpoint-staging"