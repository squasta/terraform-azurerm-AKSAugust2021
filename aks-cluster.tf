
#            _  __ _____    _____ _           _            
#      /\   | |/ // ____|  / ____| |         | |           
#     /  \  | ' /| (___   | |    | |_   _ ___| |_ ___ _ __ 
#    / /\ \ |  <  \___ \  | |    | | | | / __| __/ _ \ '__|
#   / ____ \| . \ ____) | | |____| | |_| \__ \ ||  __/ |   
#  /_/    \_\_|\_\_____/   \_____|_|\__,_|___/\__\___|_|   
                                                         
# https://patorjk.com/software/taag/#p=display&f=Big&t=AKS%20Cluster                                                       

# More info about azurerm_kubernetes_cluster resource :
# see https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/azurerm/resource_arm_kubernetes_cluster.go
resource "azurerm_kubernetes_cluster" "Terra_aks" {
  name                       = var.cluster_name
  location                   = azurerm_resource_group.Terra_aks_rg.location
  resource_group_name        = azurerm_resource_group.Terra_aks_rg.name
  dns_prefix                 = var.dns_name
  kubernetes_version         = var.kubernetes_version
  enable_pod_security_policy = var.defaultpool-securitypolicy
  sku_tier                   = var.sku-controlplane
  private_cluster_enabled    = var.enable-privatecluster
  # automatic_channel_upgrade = var.automatic-channel-upgrade        # this feature can not be used with Azure Spot nodes
 
  depends_on = [azurerm_log_analytics_workspace.Terra-LogsWorkspace]

  default_node_pool {
    name                = var.defaultpool-name
    node_count          = var.defaultpool-nodecount
    vm_size             = var.defaultpool-vmsize
    os_disk_size_gb     = var.defaultpool-osdisksizegb
    max_pods            = var.defaultpool-maxpods
    availability_zones  = var.defaultpool-availabilityzones
    enable_auto_scaling = var.defaultpool-enableautoscaling
    min_count           = var.defaultpool-mincount
    max_count           = var.defaultpool-maxcount
    vnet_subnet_id      = azurerm_subnet.Terra_aks_subnet.id
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  windows_profile {
    admin_username = var.windows_admin_username
    # Windows admin password is stored as a secret in an Azure Keyvault. Check datasource.tf for more information
    admin_password = data.azurerm_key_vault_secret.windows_admin_password.value
  }

  network_profile {
    network_plugin = "azure" # Can be kubenet (Basic Network) or azure (=Advanced Network)
    # network_policy     = var.networkpolicy_plugin # Options are calico or azure - only if network plugin is set to azure
    dns_service_ip     = "10.0.0.10" # Required when network plugin is set to azure, must be in the range of service_cidr and above 1
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.0.0/16" # Must not overlap any address from the VNet
    load_balancer_sku  = "Standard"    # sku can be basic or standard. Here it an AKS cluster with AZ support so Standard SKU is mandatory
  }

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.Terra-LogsWorkspace.id
    }
    
    # Enable HTTP Application routing (Ingress for Test and Dev only)
    http_application_routing {
      enabled = false
    }

    # Enable Azure Container Instance as a Virtual Kubelet
    # aci_connector_linux {
    #   enabled = true
    #   # https://github.com/terraform-providers/terraform-provider-azurerm/issues/3998
    #   subnet_name = azurerm_subnet.Terra_aks_aci_subnet.name
    # }

    # Enable Azure Policy
    # cf. https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
    azure_policy {
      enabled = var.enable-AzurePolicy
    }

    # Enable Azure Application Gateway Ingress Controller
    ingress_application_gateway {
      enabled = true
      # gateway_id = ""                       # for Brownfield deployment if you already set up an Application Gateway
      gateway_name ="appgw-aks-july21"        # Greenfield deployment, this gateway will be created in cluster resource group.
      # subnet_cidr = "10.252.0.0/16"
      subnet_id = azurerm_subnet.Terra_aks_appgw_subnet.id
    }


  }

  # Enable Kubernetes RBAC 
  role_based_access_control {
    enabled = true               # please do NOT set up RBAC to false !!!
  }

  # Managed Identity is mandatory because Kubernetes will provision some Azure Resources like Azure Load Balancer, Public IP, Managed Disks... 
  # You can also use a Service Principal (but it more complicated). One of either identity or service_principal must be specified
  identity {
    type = "SystemAssigned"
  }


  tags = {
    Usage       = "Demo"
    Environment = "Demo"
  }
}



# AKS Agent node-pool cf. https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html
# resource "azurerm_kubernetes_cluster_node_pool" "Terra-AKS-NodePools" {
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.Terra_aks.id
#   name                  = "spotspool"
#   depends_on            = [azurerm_kubernetes_cluster.Terra_aks]
#   node_count            = 1          # static number or initial number of nodes. Must be between 1 to 100
#   enable_auto_scaling   = true       # use this parameter if you want an AKS Cluster with Node autoscale. Need also min_count and max_count
#   min_count             = 0          # minimum number of nodes with AKS Autoscaler
#   max_count             = 3          # maximum number of nodes with AKS Autoscaler
#   vm_size               = "Standard_D5_v2"
#   availability_zones    = var.winpool-availabilityzones # example : [1, 2, 3]
#   os_type               = "Linux"        # Possible values :linux, windows
#   os_disk_size_gb       = 128
#   vnet_subnet_id = azurerm_subnet.Terra_aks_subnet.id
#   mode = "User"
#   # priority = Regular or Spot
#   priority = "Spot"                                     # not compatible with cluster autoupgrade
#   eviction_policy = "Delete"                            # possible value : Delete, Deallocate
#   spot_max_price  = "-1"
#   node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
# }








#               _     _ _ _   _                         _                   _                          _ 
#      /\      | |   | (_) | (_)                       | |                 | |                        | |
#     /  \   __| | __| |_| |_ _  ___  _ __  _ __   __ _| |    _ __   ___   __| | ___   _ __   ___   ___ | |
#    / /\ \ / _` |/ _` | | __| |/ _ \| '_ \| '_ \ / _` | |   | '_ \ / _ \ / _` |/ _ \ | '_ \ / _ \ / _ \| |
#   / ____ \ (_| | (_| | | |_| | (_) | | | | | | | (_| | |   | | | | (_) | (_| |  __/ | |_) | (_) | (_) | |
#  /_/    \_\__,_|\__,_|_|\__|_|\___/|_| |_|_| |_|\__,_|_|   |_| |_|\___/ \__,_|\___| | .__/ \___/ \___/|_|
#                                                                                   | |                  
#                                                                                   |_|                 


# AKS Agent node-pool cf. https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html
# resource "azurerm_kubernetes_cluster_node_pool" "Terra-AKS-NodePools" {
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.Terra_aks.id
#   name                  = var.windowspool-name
#   depends_on            = [azurerm_kubernetes_cluster.Terra_aks]
#   node_count            = var.windowspool-nodecount     # static number or initial number of nodes. Must be between 1 to 100
#   enable_auto_scaling   = var.winpool-enableautoscaling # use this parameter if you want an AKS Cluster with Node autoscale. Need also min_count and max_count
#   min_count             = var.winpool-mincount          # minimum number of nodes with AKS Autoscaler
#   max_count             = var.winpool-maxcount          # maximum number of nodes with AKS Autoscaler
#   vm_size               = var.windowspool-vmsize
#   availability_zones    = var.winpool-availabilityzones # example : [1, 2, 3]
#   os_type               = var.windowspool-ostype        # Possible values :linux, windows
#   os_disk_size_gb       = var.windowspool-osdisksizegb
#   # max_pods              = var.winpool-maxpods         # between 30 and 250. BUT must 30 max for Windows Node
#   vnet_subnet_id = azurerm_subnet.Terra_aks_subnet.id
#   node_taints    = var.winpool-nodetaints               # cf. https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
#   mode = "User"
#   # priority = Regular or Spot
#   priority = "Spot"                                     # not compatible with cluster autoupgrade
#   eviction_policy = "Delete"                            # possible value : Delete, Deallocate
#   spot_max_price  = "-1"
#   # node_labels = "kubernetes.azure.com/scalesetpriority:spot"
#   # node_taints = "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
# }




# Role Assignment to give AKS managed identity Contributor permissions on the ACI resource group - Required for Virtual Kubelet
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#delegate-access-to-other-azure-resources
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#azure-container-instances 
# resource "azurerm_role_assignment" "Terra-aks-aci-role" {
#   scope                = azurerm_resource_group.Terra_aks_rg.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_kubernetes_cluster.Terra_aks.kubelet_identity.0.object_id
# }

