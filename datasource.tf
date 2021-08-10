#   _____        _                                          
#  |  __ \      | |                                         
#  | |  | | __ _| |_ __ _ ___  ___  _   _ _ __ ___ ___  ___ 
#  | |  | |/ _` | __/ _` / __|/ _ \| | | | '__/ __/ _ \/ __|
#  | |__| | (_| | || (_| \__ \ (_) | |_| | | | (_|  __/\__ \
#  |_____/ \__,_|\__\__,_|___/\___/ \__,_|_|  \___\___||___/
                                                          

data "azurerm_key_vault" "terraform_vault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ClePubliqueSSH" # must looks like "ssh-rsa AAAABxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx email@domaine.name"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "spn_id" {
  name         = "spn-id"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}
data "azurerm_key_vault_secret" "spn_secret" {
  name         = "spn-secret"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

# you can get object_id value with the following az cli command :
# az ad sp show --id XXXXXXX-XXXX-xxxxx-xxxxxxxxxxxxx -o jsonc  where xxxxxx is your Application (Client ID)
data "azurerm_key_vault_secret" "spn_object_id" {
  name         = "spn-object-id"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "windows_admin_password" {
  name         = "windows-admin-password"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}
