# Azure Subscription ID
variable "subscription_id" {
  type      = string
  default   = "c239ae51-b616-4e89-84e0-79ebee7c62fc"
  sensitive = true
}

# Definir location
variable "location_name" {
  type    = string
  default = "East US 2"
}

# Tamanho da VM
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

# Imagem
variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts"
}

variable "image_version" {
  type    = string
  default = "latest"
}

# Quantidades de VMs
variable "qts_vms" {
  type    = number
  default = 2
}

# Horário do desligamento automático das VMs
variable "horario_shutdown" {
  type    = string
  default = "2030"
}

# Ativar/desativar o auto-shutsown
variable "enable_shutdown" {
  type    = string
  default = "true"
}