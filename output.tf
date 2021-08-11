#    ____        _               _   
#   / __ \      | |             | |  
#  | |  | |_   _| |_ _ __  _   _| |_ 
#  | |  | | | | | __| '_ \| | | | __|
#  | |__| | |_| | |_| |_) | |_| | |_ 
#   \____/ \__,_|\__| .__/ \__,_|\__|
#                   | |              
#                   |_|              

# output "client_certificate" {
#   value = "${azurerm_kubernetes_cluster.Terra_aks.kube_config.0.client_certificate}"
# }

# output "kube_config" {
#   value = "${azurerm_kubernetes_cluster.Terra_aks.kube_config_raw}"
#   #  value = "${azurerm_kubernetes_cluster.Terra_aks_rg.kube_config_raw}"
#   sensitive = true
# }

# output "Application_Gateway" {
#   value = "${azurerm_kubernetes_cluster.Terra_aks.addon_profile[0].ingress_application_gateway[0].effective_gateway_id}"
# }

output "URL-to-connect-Grafana-through-AppGW-Ingress" {
  value = "http://${var.a-record-dns-ingress}.${var.dns-zone-name-for-ingress}   no https. i know: it is just for test purpose !"
}
