output "resource_group_name" {
  value = azurerm_resource_group.wordpress-rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.wordpress-rg.location
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.cluster-aks.name
}

# output "host" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.host
# }

# output "client_key" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
# }

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.default.kube_config_raw
# }

# output "cluster_username" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.username
# }

# output "cluster_password" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.password
# }

#config kubectl
#az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)

#access k8s dashboard
#kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --user=clusterUser
#az aks browse --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)

#generate token
#kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')

##https://learn.hashicorp.com/tutorials/terraform/aks?in=terraform/kubernetes
##https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider