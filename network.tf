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

# IP público
resource "azurerm_public_ip" "public_ip" {
  for_each            = local.nics
  name                = each.value.ip_public_name
  resource_group_name = azurerm_resource_group.k8s_vms.name
  location            = azurerm_resource_group.k8s_vms.location
  allocation_method   = "Static"
}


# Criar uma interface de rede
resource "azurerm_network_interface" "nic" {
  for_each            = local.nics
  name                = each.value.nic_name
  location            = azurerm_resource_group.k8s_vms.location
  resource_group_name = azurerm_resource_group.k8s_vms.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip_address
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

# Configuração do Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "k8s_nsg"
  location            = azurerm_resource_group.k8s_vms.location
  resource_group_name = azurerm_resource_group.k8s_vms.name
}

resource "azurerm_network_security_rule" "example" {
  name                        = "Rules"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k8s_vms.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

locals {
  nics = {
    for i in range(1, 1 + var.qts_vms) :
    i => {
      ip_public_name = format("ippublic%d", i)
      nic_name       = format("nic%d", i)
      ip_address     = format("10.0.2.%d", 10 + i)
    }

  }
}
