# Definir location
variable "location_name" {
  type    = string
  default = "East US 2"
}


#### Escolha a imagem da VM (Sistema Operacional)
# Use somente image GEN 2 e distribuições baseadas em Debian (Ubuntu, etc)
# Se usar uma distribuição diferente do Debian tem que alterar o repositório do
# containerd no arquivo "cloudinit.tf".
# https://az-vm-image.info/?cmd=--all+--sku+GEN2
variable "image_publisher" {
  type    = string
  default = "Debian"
}

variable "image_offer" {
  type    = string
  default = "debian-12"
}

variable "image_sku" {
  type    = string
  default = "12-gen2"
}

variable "image_version" {
  type    = string
  default = "latest"
}
####


#### Ativar/desativar o auto-shutsown
variable "enable_shutdown" {
  type    = string
  default = "true"
}

# Horário do desligamento automático das VMs
variable "horario_shutdown" {
  type    = string
  default = "2030"
}
####


# Timezone das VMs
variable "timezone_vms" {
  type    = string
  default = "America/Sao_Paulo"
}

# Escolha se deseja usar VM Spot ou Regular (VM normal)
# Se não for usar VM Spot comente o 'default' de cima e descomente o de baixo
variable "vm_spot" {
  type    = string
  default = "Spot"
  # default = "Regular  
}

# Tamanho da VM
# Usar imagem que suporte VM GEN 2
# https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

# Quantidades de VMs que serão utilizadas. 
# Uma VM será o Control Plane e as demais serão os Workers.
# Use no mínimo 02 VMs.
variable "qts_vms" {
  type    = number
  default = 3
}