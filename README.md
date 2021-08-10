# Azure Kubernetes Service Cluster deployment with Terraform


           _  __ _____   _______                   __                        _____                       _         __             _                _                           
     /\   | |/ // ____| |__   __|                 / _|                      / ____|                     | |       / _|           | |              (_)                          
    /  \  | ' /| (___      | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___   | (___   __ _ _ __ ___  _ __ | | ___  | |_ ___  _ __  | |__   ___  __ _ _ _ __  _ __   ___ _ __ ___ 
   / /\ \ |  <  \___ \     | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \   \___ \ / _` | '_ ` _ \| '_ \| |/ _ \ |  _/ _ \| '__| | '_ \ / _ \/ _` | | '_ \| '_ \ / _ \ '__/ __|
  / ____ \| . \ ____) |    | |  __/ |  | | | (_| | || (_) | |  | | | | | |  ____) | (_| | | | | | | |_) | |  __/ | || (_) | |    | |_) |  __/ (_| | | | | | | | |  __/ |  \__ \
 /_/    \_\_|\_\_____/     |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| |_____/ \__,_|_| |_| |_| .__/|_|\___| |_| \___/|_|    |_.__/ \___|\__, |_|_| |_|_| |_|\___|_|  |___/
                                                                                                  | |                                         __/ |                            
                                                                                                  |_|                                        |___/                             


=== Still work in progress === version up to date July 2021

= Tested with success with 
Terraform v1.0.3
on linux_amd64 (WSL2)
+ provider registry.terraform.io/hashicorp/azurerm v2.70.0
+ provider registry.terraform.io/hashicorp/helm v2.2.0
+ provider registry.terraform.io/hashicorp/kubernetes v2.3.2
+ provider registry.terraform.io/hashicorp/random v3.1.0

--------------------------------------------------------------------------------------------------------

This is a set of Terraform files used to deploy an Azure Kubernetes Cluster with some cool features :

- Nodes will be dispatched in different Availability Zones (AZ)
- Node pools will support Autoscaling
- pool1 is a linux node pool (it is mandatory because of kube system pods)
- pool2 (optional) is a windows server 2019 node pool with a taint
- System Managed Identities are used instead of Service Principal
- Choice of SKU (Free or Paid) for Azure Kubernetes Service (Control Plane)

These Terraform files can be used to deploy the following Azure components :

- An Azure Resource Group
- An Azure Kubernetes Services Cluster with 1 node pool running Linux 
- An additionnal node pool (pool2) with Windows Server 2019 nodes
- An Azure Load Balancer Standard SKU
- A Virtual Network with it Subnets (subnet for AKS Pods, subnets for AzureBastion and AzureFirewall/NVA if needed, Azure Application Gateway)
- Azure Application Gateway + Application Gateway Ingress Controller AKS add-on
- An Azure Log Analytics Workspace (used for Azure Monitot Container Insight)

On Kubernetes, these Terraform files will :

- Create a ClusterRole Binding to give cluster-admin permissions to Kubernetes-Dashboard (usefull if Kubernetes version <1.16)
- Deploy Grafana using Bitnami Helm Chart and exposed Grafana Dashboard using Ingress

__Prerequisites :__

- An Azure Subscription with enough privileges (create RG, AKS...)
- Azure CLI 2.26.1 or >: <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest>
   And you need to activate features that are still in preview and add extension aks-preview to azure CLI (az extension add --name aks-preview)
- Terraform CLI 1.0.3 or > : <https://www.terraform.io/downloads.html>
- Helm CLI 3.6.3 or > : <https://helm.sh/docs/intro/install/> if you need to test Helm charts

__To deploy this infrastructure :__

1. Log to your Azure subscription (az login)
2. Create an Azure Key Vault and create all secrets defined in datasource.tf
3. Define the value of each variable in .tf and/or .tfvars files
4. Initialize your terraform deployment : `terraform init`
5. Plan your terraform deployment : `terraform plan --var-file=myconf.tfvars`
6. Apply your terraform deployment : `terraform apply --var-file=myconf.tfvars`

__For more information about Terraform & Azure, Kubernetes few additional online resources :__

- My blog : <https://stanislas.io>
- Julien's blog : <https://blog.jcorioland.io/>
- Terraform documentation : <https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html>
- Azure Terraform Provider : <https://github.com/terraform-providers/terraform-provider-azurerm>
- Azure Terraform Provider AKS Cluster : <https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/azurerm/resource_arm_kubernetes_cluster.go>
- Guide for scheduling Windows containers in Kubernetes
 <https://kubernetes.io/docs/setup/production-environment/windows/user-guide-windows-containers/>

After deployment is succeeded, you can check your cluster using portal or better with azure cli and the following command: 
`az aks show --resource-group NAMEOFYOURRESOURCEGROUP --name NAMEOFYOURAKSCLUSTER -o jsonc`

Get your kubeconfig using :

`az aks get-credentials --resource-group NAMEOFYOURRESOURCEGROUP --name NAMEOFYOURAKSCLUSTER --admin`

![Magic](https://github.com/squasta/AzureKubernetesService-Terraform/raw/master/Magic.gif)
