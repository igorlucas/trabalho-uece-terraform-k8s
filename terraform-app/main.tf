terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.42.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "aks" {
  backend = "local"

  config = {
    path = "../terraform-aks-cluster/terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = data.terraform_remote_state.aks.outputs.kubernetes_cluster_name
  resource_group_name = data.terraform_remote_state.aks.outputs.resource_group_name
}

provider "azurerm" {
  version = ">=2.20.0"
  features {}
}

provider "kubernetes" {
  host = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host

  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
}

// resource "azurerm_managed_disk" "mysql-md" {
//   name                 = "mysql-md"
//   location             = data.terraform_remote_state.aks.outputs.resource_group_location
//   resource_group_name  = data.terraform_remote_state.aks.outputs.resource_group_name
//   storage_account_type = "Standard_LRS"
//   create_option        = "Empty"
//   disk_size_gb         = "10"
//   tags = {
//     environment = data.terraform_remote_state.aks.outputs.resource_group_name
//   }
// }

// resource "kubernetes_persistent_volume" "mysql-pv" {
//   metadata {
//     name = "mysql-pv"
//   }
//   spec {
//     capacity = {
//       storage = "10Gi"
//     }
//     access_modes = ["ReadWriteOnce"]
//     persistent_volume_source {
//       azure_disk {
//         caching_mode  = "None"
//         data_disk_uri = azurerm_managed_disk.mysql-md.id
//         disk_name     = "mysql"
//         kind          = "Managed"
//       }
//     }
//   }
// }

// resource "kubernetes_persistent_volume_claim" "mysql-pvc" {
//   metadata {
//     name = "mysql-pvc"
//     namespace = "default"
//   }
//   spec {
//     access_modes = ["ReadWriteMany"]
//     storage_class_name = ""
//     resources {
//       requests = {
//         storage = "5Gi"
//       }
//     }
//     volume_name = "${kubernetes_persistent_volume.mysql-pv.metadata.0.name}"
//   }
// }

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql-deployment"
    #namespace = ""
    labels = {
      app = "mysql-server"
      deploymentName = "mysql-deployment"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql-server"
        deploymentName = "mysql-deployment"
      }
    }
    // strategy {
    //   type = "Recreate"
    // }
    template {
      metadata {
        name = "mysql-pod"
        labels = {
          app = "mysql-server"
          deploymentName = "mysql-deployment"
        }
      }
      spec {
        container {
          image = "mysql:5.6"
          name  = "mysql"
          
          env {
                name = "MYSQL_ROOT_PASSWORD"
                value = var.MYSQL_ROOT_PASSWORD
              }
          
          env {
                name = "MYSQL_DATABASE"
                value = var.MYSQL_DATABASE
              }

          env {
                name = "MYSQL_USER"
                value = var.MYSQL_USER
              }

          env {
                name = "MYSQL_PASSWORD"
                value = var.MYSQL_PASSWORD
              }
          
          port {
            container_port = 3306
          }
          
          volume_mount {
            name = "storage"
            mount_path = "/var/lib/msql"
            sub_path = "mysql"
          }
        }

        volume {
          name = "storage"
          // persistent_volume_claim {
          //   claim_name = kubernetes_persistent_volume_claim.mysql-pvc.metadata[0].name
          // }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql-server-svc"
    #namespace = ""
  }
  spec {
    selector = {
      app = kubernetes_deployment.mysql.spec.0.template.0.metadata[0].labels.app
      deploymentName = kubernetes_deployment.mysql.spec.0.template.0.metadata[0].labels.deploymentName
    }
    
    #selector = var.mysql_selectors
    
    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
}


## WORDPRESS
resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress-deployment"
    labels = {
      App = "WordpressDeployment"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "WordpressDeployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "WordpressDeployment"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress"

          port {
            container_port = 80
          }
          
          env  {
              name = "WORDPRESS_DB_HOST"
              value = kubernetes_service.mysql.spec.0.cluster_ip
              #value = "remotemysql.com"
          }

          env  {
              name = "WORDPRESS_DB_USER"
              value = var.MYSQL_USER
              #value = "2oOcDMkddX"            
          }

          env  {
              name = "WORDPRESS_DB_PASSWORD"
              value = var.MYSQL_PASSWORD 
              #value = "lwZY9rTzBu"            
          }

          env  {
              name = "WORDPRESS_DB_NAME"
              value = var.MYSQL_DATABASE
              #value = "2oOcDMkddX"            
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

output "lb_ip_wp" {
  value = kubernetes_service.wordpress.status.0.load_balancer.0.ingress.0.ip
}

output "mysql-svc-ip" {
  value = kubernetes_service.mysql.spec.0.cluster_ip
}



