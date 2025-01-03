data "azurerm_resource_group" "aks_rg" {
  name = var.cluster_resource_group_name
}

data "azurerm_kubernetes_cluster" "main" {
  name                = var.kubernetes_cluster_name
  resource_group_name = var.cluster_resource_group_name
}


data "azurerm_public_ip" "ingress_static_ip" {
  name = var.ingress_static_ip_name
  resource_group_name = var.cluster_resource_group_name
}

output "ingress_public_ip_address" {
  value = data.azurerm_public_ip.ingress_static_ip.ip_address
  description = "The public static IP of nginx-ingress for frontend"
}

resource "kubernetes_namespace" "project" {
  metadata {
    name = var.kubernetes_namespace_name
  }
}

## Pod identity is used to allow AKS pods to talk with Azure services
resource "azurerm_user_assigned_identity" "pod-identity" {
  resource_group_name = var.cluster_resource_group_name
  location            = var.location
  name                = "aadid-${var.project}-${var.env}"
}

# grant assignments to the managed identity

resource "azurerm_role_assignment" "aks_rg_reader" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.pod-identity.principal_id
}

resource "azurerm_role_assignment" "mio_rg" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_kubernetes_cluster.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "rg_ip_access" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.main.identity[0].principal_id
}

# install kubernetes services

resource "helm_release" "cert-manager" {
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  name = "cert-manager"
  version = "1.8.0"


  set {
    name = "installCRDs"
    value = true
  }

  set {
    name = "nodeSelector\\.beta\\.kubernetes\\.io/os"
    value = "linux"
  }
}



resource "helm_release" "nginx-ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  name = "nginx-ingress"
  version = "4.1.3"
  namespace = "${var.project}-dev"
  #namespace = "${var.project}-${var.env}"

  set {
    name = "replicaCount"
    value = 2
  }

  set {
    name = "nodeSelector.\\.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name = "controller.enableExternalDNS"
    value = "true"
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = "ghallocation-${var.env}"
  }

  ## This is the resource group where public static IP address must be located.
  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = data.azurerm_resource_group.aks_rg.name
    #value = "rg-resourceplanning-test-westeu-001"
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = data.azurerm_public_ip.ingress_static_ip.ip_address
  }

  # set {
  #   name = "controller.service.externalTrafficPolicy"
  #   value = "Local"
  # }
}
