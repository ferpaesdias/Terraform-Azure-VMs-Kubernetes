# Criar Resource Group
resource "azurerm_resource_group" "k8s_vms" {
  name     = "K8S_VMs"
  location = var.location_name
}

# Criar VM
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on            = [tls_private_key.ssh, local_file.ssh_private_key, local_file.ssh_public_key, ]
  for_each              = local.nodes
  name                  = each.value.node_name
  computer_name         = each.value.node_name
  resource_group_name   = azurerm_resource_group.k8s_vms.name
  location              = azurerm_resource_group.k8s_vms.location
  size                  = var.vm_size
  admin_username        = "adminuser"
  custom_data           = base64encode(local.custom_data)
  network_interface_ids = [azurerm_network_interface.nic[each.key].id, ]
  admin_ssh_key {
    username   = "adminuser"
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

# Configuração de auto-shutdown das VMs
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_vms" {
  for_each           = local.nodes
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  location           = azurerm_resource_group.k8s_vms.location
  enabled            = var.enable_shutdown

  daily_recurrence_time = var.horario_shutdown
  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  timezone = "E. South America Standard Time"

  notification_settings {
    enabled = false
  }
}
