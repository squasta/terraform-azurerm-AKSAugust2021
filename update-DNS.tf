
# small timer to wait the public IP of Application Gateway (created by AKS AGIC add-on) to be ready
# cf. https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_kubernetes_cluster.Terra_aks]

  create_duration = "30s"
}


# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "Terra-Public-IP-AppGW" {
  # terraform apply can make an error like : Public IP "appgw-xxxxx-appgwpip" (Resource Group "MC_RG-axxxxx_xxxxx_CentralUS") was not found
  # because Public IP is not yet readycount 
  # Solution is to run again terraform apply
  # I use here an AppGw provisionned in Greenfield mode as a n aks add-on. So there is no Terraform resource for this Ip
  # That is why i use a datasource for updating DNS Record
  depends_on = [time_sleep.wait_30_seconds]
  name                = "${azurerm_kubernetes_cluster.Terra_aks.addon_profile[0].ingress_application_gateway[0].gateway_name}-appgwpip"     # defaultname : NAMEOFAZUREAPPGATEWAY-appgwpip
  resource_group_name = "MC_${var.resource_group}_${var.cluster_name}_${var.azure_region}"                 # defaultname : MC_NAMEOFRESOURCEGROUP_NAMEOFAKSCLUSTER_AZUREREGION
}

# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record
resource "azurerm_dns_a_record" "Terra-Ingress-DNS-A-Record" {
  name = var.a-record-dns-ingress
  zone_name = var.dns-zone-name-for-ingress
  resource_group_name = var.rg-name-dns-zone-for-ingress
  # name = "demoingress1"
  # zone_name = "standemo.com" 
  # resource_group_name = "rg-azuredns"
  ttl                 = 100
  records             = ["${data.azurerm_public_ip.Terra-Public-IP-AppGW.ip_address}"]
}