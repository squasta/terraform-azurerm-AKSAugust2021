variable "a-record-dns-ingress" {
    type = string
    default = "demoingress1"
}

variable "dns-zone-name-for-ingress" {
    type = string
    default = "standemo.com"
}

variable "rg-name-dns-zone-for-ingress" {
    type = string
    default = "rg-azuredns"
}