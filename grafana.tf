#    _____            __                  
#   / ____|          / _|                 
#  | |  __ _ __ __ _| |_ __ _ _ __   __ _ 
#  | | |_ | '__/ _` |  _/ _` | '_ \ / _` |
#  | |__| | | | (_| | || (_| | | | | (_| |
#   \_____|_|  \__,_|_| \__,_|_| |_|\__,_|
#
# Deployment with Helm
# Exposed on Internet using Azure Application Gatewaty Ingress Controller
  

resource "helm_release" "Terra-grafana2" {
  name       = "my-grafana-from-bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"
  #timeout    = 600

  set {
    name  = "admin.user"
    value = var.grafana_admin_username
  }

  set {
    name  = "admin.password"
    value = data.azurerm_key_vault_secret.grafana_admin_password.value
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.storageClass"
    value = "default"
  }

  set {
    name  = "persistence.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name  = "persistence.size"
    value = "1Gi"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # set {
  #   name  = "tolerations"
  #   value = "os=linux:NoSchedule"
  # }

}


resource "kubernetes_ingress" "Terra-Ingress-Grafana" {
  metadata {
    name = "ingress-grafana"
    annotations = {
      # "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/ingress.class" = "azure/application-gateway"      
    }
  }

  spec {
    backend {
      service_name = "my-grafana-from-bitnami"
      service_port = 3000
    }

    rule {
      http {
        path {
          backend {
            service_name = "my-grafana-from-bitnami"
            service_port = 3000
          }

          path = "/*"
        }

        # path {
        #   backend {
        #     service_name = "MyApp2"
        #     service_port = 8080
        #   }

        #   path = "/app2/*"
        # }
      }
    }

    # tls {
    #   secret_name = "tls-secret"
    # }
  }
}
