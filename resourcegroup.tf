#                                   _____                                        _____                       
#      /\                          |  __ \                                      / ____|                      
#     /  \    _____   _ _ __ ___   | |__) |___  ___  ___  _   _ _ __ ___ ___   | |  __ _ __ ___  _   _ _ __  
#    / /\ \  |_  / | | | '__/ _ \  |  _  // _ \/ __|/ _ \| | | | '__/ __/ _ \  | | |_ | '__/ _ \| | | | '_ \ 
#   / ____ \  / /| |_| | | |  __/  | | \ \  __/\__ \ (_) | |_| | | | (_|  __/  | |__| | | | (_) | |_| | |_) |
#  /_/    \_\/___|\__,_|_|  \___|  |_|  \_\___||___/\___/ \__,_|_|  \___\___|   \_____|_|  \___/ \__,_| .__/ 
#                                                                                                     | |    
#                                                                                                     |_|    

# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "Terra_aks_rg" {
  name     = var.resource_group
  location = var.azure_region
}
