# Criar Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet_k8s_vms"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.k8s_vms.location
  resource_group_name = azurerm_resource_group.k8s_vms.name
}

# Criar uma subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet_k8s_vms"
  resource_group_name  = azurerm_resource_group.k8s_vms.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Criar uma interface de rede
resource "azurerm_network_interface" "nic" {
  name                = "nic_k8s_vms"
  location            = azurerm_resource_group.k8s_vms.location
  resource_group_name = azurerm_resource_group.k8s_vms.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}