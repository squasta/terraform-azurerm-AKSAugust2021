
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "Terra-Public-IP-AppGW" {
  name                = "${azurerm_kubernetes_cluster.Terra_aks.addon_profile[0].ingress_application_gateway[0].gateway_name}-appgwpip"     # defaultname : NAMEOFAZUREAPPGATEWAY-appgwpip
  # resource_group_name = "MC_RG-aks-july21_aks-july21_centralus"                                          # defaultname : MC_NAMEOFRESOURCEGROUP_NAMEOFAKSCLUSTER_AZUREREGION
  resource_group_name = "MC_${var.resource_group}_${var.cluster_name}_${var.azure_region}"                 # defaultname : MC_NAMEOFRESOURCEGROUP_NAMEOFAKSCLUSTER_AZUREREGION
}

# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record
resource "azurerm_dns_a_record" "Terra-Ingress-DNS-A-Record" {
  name                = "demoingress1"
  zone_name           = "standemo.com" 
  resource_group_name = "rg-azuredns"
  ttl                 = 100
  records             = ["${data.azurerm_public_ip.Terra-Public-IP-AppGW.ip_address}"]
}