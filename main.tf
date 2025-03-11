# Criar Resource Group
resource "azurerm_resource_group" "k8s_vms" {
  name     = "k8s_vms"
  location = var.location_name
}

# Criar VM
resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = local.nodes
  name                  = each.value.node_name
  computer_name         = each.value.node_name
  resource_group_name   = azurerm_resource_group.k8s_vms.name
  location              = azurerm_resource_group.k8s_vms.location
  size                  = var.vm_size
  admin_username        = var.admin_user
  network_interface_ids = [azurerm_network_interface.nic[each.key].id, ]
  admin_ssh_key {
    username   = var.admin_user
    public_key = join("\n", local.authorized_keys)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}

locals {
  nodes = {
    for i in range(1, 1 + var.qts_vms) :
    i => {
      node_name = format("node%d", i)
    }
  }
}