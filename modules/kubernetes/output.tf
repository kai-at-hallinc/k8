output "aks_principal_id" {
  description = "Resource ID of the Key Vault."
  value       = module.aks.cluster_identity.principal_id
}

output "kubelet_identity_object_id" {
  value = module.aks.kubelet_identity[0].object_id
}