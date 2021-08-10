#   _______                   __                        _____                      _          ____             _                  _ 
#  |__   __|                 / _|                      |  __ \                    | |        |  _ \           | |                | |
#     | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___    | |__) |___ _ __ ___   ___ | |_ ___   | |_) | __ _  ___| | _____ _ __   __| |
#     | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \   |  _  // _ \ '_ ` _ \ / _ \| __/ _ \  |  _ < / _` |/ __| |/ / _ \ '_ \ / _` |
#     | |  __/ |  | | | (_| | || (_) | |  | | | | | |  | | \ \  __/ | | | | | (_) | ||  __/  | |_) | (_| | (__|   <  __/ | | | (_| |
#     |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_|  |_|  \_\___|_| |_| |_|\___/ \__\___|  |____/ \__,_|\___|_|\_\___|_| |_|\__,_|
                                                                                                                                  

# A remote backend must be used for production (especially if deployments are done through CI/CD pipelines) 
# or if you are not working only with yourself as a lone ranger :)


###################################################################################
# Option 1 for Terraform Remote Backend : use Terraform Cloud Remote State Management
# https://www.hashicorp.com/blog/introducing-terraform-cloud-remote-state-management
# create your account here : https://app.terraform.io/session
####################################################################################
# Using a single workspace in Terraform Cloud Remote State / Terraform Enterprise
# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "Insert here your organization name"
#     token = "Insert here your Token"
#     workspaces {
#       name = "deploiementVM-AKS"
#     }
#   }
# }


###################################################################################
# Option 2 for Terraform Remote Backend : use an Azure Storage Account
# ref : https://www.terraform.io/docs/backends/types/azurerm.html
####################################################################################
# You need as a prerequisite :
# A storage Account with a blob container into your deployment region
# Enable Secure Transfert Required option to force TLS usage
# create a blob container named terraform-state

# data "terraform_remote_state" "Terra-Backend-Stan1" {
#    backend = "azure"
#    config {
#        storage_account_name = "mettre ici le nom du compte de stockage"
#        container_name = "terraform-state"
#        key = "prod.terraform.tfstate"
#    }
# }