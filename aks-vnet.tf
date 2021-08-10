
# Defining the AKS Virtual Network
#  __      ___      _               _    _   _      _                      _                       _     _____       _                _       
#  \ \    / (_)    | |             | |  | \ | |    | |                    | |                     | |   / ____|     | |              | |      
#   \ \  / / _ _ __| |_ _   _  __ _| |  |  \| | ___| |___      _____  _ __| | __    __ _ _ __   __| |  | (___  _   _| |__  _ __   ___| |_ ___ 
#    \ \/ / | | '__| __| | | |/ _` | |  | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /   / _` | '_ \ / _` |   \___ \| | | | '_ \| '_ \ / _ \ __/ __|
#     \  /  | | |  | |_| |_| | (_| | |  | |\  |  __/ |_ \ V  V / (_) | |  |   <   | (_| | | | | (_| |   ____) | |_| | |_) | | | |  __/ |_\__ \
#      \/   |_|_|   \__|\__,_|\__,_|_|  |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\   \__,_|_| |_|\__,_|  |_____/ \__,_|_.__/|_| |_|\___|\__|___/                                                                                                                                     
                                                                                                                                          

resource "azurerm_virtual_network" "Terra_aks_vnet" {
  name                = var.aks_vnet_name
  resource_group_name = azurerm_resource_group.Terra_aks_rg.name
  location            = azurerm_resource_group.Terra_aks_rg.location
  address_space       = ["10.0.0.0/8"]
}

# Role Assignment to give AKS the access to VNET - Required for Advanced Networking
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#delegate-access-to-other-azure-resources
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#networking
resource "azurerm_role_assignment" "Terra-aks-vnet-role" {
  scope                = azurerm_virtual_network.Terra_aks_vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.Terra_aks.kubelet_identity.0.object_id
}

# Defining subnets Virtual Network

resource "azurerm_subnet" "Terra_aks_subnet" {
  name                 = "aks_subnet"
  resource_group_name  = azurerm_resource_group.Terra_aks_rg.name
  virtual_network_name = azurerm_virtual_network.Terra_aks_vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

# Role Assignment to give AKS the access to AKS subnet
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#delegate-access-to-other-azure-resources
# cf. https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#networking
resource "azurerm_role_assignment" "Terra-aks-subnet-role" {
  scope                = azurerm_subnet.Terra_aks_subnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.Terra_aks.kubelet_identity.0.object_id
}


resource "azurerm_subnet" "Terra_aks_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.Terra_aks_rg.name
  virtual_network_name = azurerm_virtual_network.Terra_aks_vnet.name
  address_prefixes     = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "Terra_aks_firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.Terra_aks_rg.name
  virtual_network_name = azurerm_virtual_network.Terra_aks_vnet.name
  address_prefixes     = ["10.253.0.0/16"]
}

resource "azurerm_subnet" "Terra_aks_aci_subnet" {
  name                 = "virtual-node-aci"
  resource_group_name  = azurerm_resource_group.Terra_aks_rg.name
  virtual_network_name = azurerm_virtual_network.Terra_aks_vnet.name
  address_prefixes     = ["10.241.0.0/16"]
  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}

# Role Assignment to Grant AKS cluster access to join ACI subnet
resource "azurerm_role_assignment" "Terra-aks-aci_subnet" {
  scope                = azurerm_subnet.Terra_aks_aci_subnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.Terra_aks.kubelet_identity.0.object_id
}

# Role Assignment to Grant ACI-connector Pod permission Contributor on ACI Subnet
# resource "azurerm_role_assignment" "Terra-aci-aci_subnet" {
#   scope                = azurerm_subnet.Terra_aks_aci_subnet.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_kubernetes_cluster.Terra_aks.aciConnectorLinux
# }



###################
# AppGateway Subnet

resource "azurerm_subnet" "Terra_aks_appgw_subnet" {
  name                 = "appgwsubnet"
  resource_group_name  = azurerm_resource_group.Terra_aks_rg.name
  virtual_network_name = azurerm_virtual_network.Terra_aks_vnet.name
  address_prefixes     = ["10.252.0.0/16"]
}
