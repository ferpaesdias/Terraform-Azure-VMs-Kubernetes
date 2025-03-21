# Criar Resource Group
resource "azurerm_resource_group" "k8s_vms" {
  name     = "K8S_VMs"
  location = var.location_name
}

# Executa o script 'vmspot.sh' para selecionar o tamanho da image VM Spot
data "external" "vmspot" {
  program = ["bash", "${path.module}/vmspot.sh"]
}

# Criar as VMs
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on          = [tls_private_key.ssh, local_file.ssh_private_key, local_file.ssh_public_key, ]
  for_each            = local.nodes
  name                = each.value.node_name
  computer_name       = each.value.node_name
  resource_group_name = azurerm_resource_group.k8s_vms.name
  location            = azurerm_resource_group.k8s_vms.location
  size                = trimspace(replace(base64decode(data.external.vmspot.result.base64), "\"", ""))
  # size                   = var.vm_size
  admin_username        = "adminuser"
  custom_data           = base64encode(local.custom_data)
  network_interface_ids = [azurerm_network_interface.nic[each.key].id, ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = join("\n", local.authorized_keys)
  }

  # Cria um disco HDD que é mais barato, porém, é mais lento
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Opção de VM Spot
  priority        = var.vm_spot
  eviction_policy = "Delete"

  # Dados da imagem (Sistema Operacional)
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}

# Configuração de auto-shutdown das VMs
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_vms" {
  for_each              = local.nodes
  virtual_machine_id    = azurerm_linux_virtual_machine.vm[each.key].id
  location              = azurerm_resource_group.k8s_vms.location
  enabled               = var.enable_shutdown
  daily_recurrence_time = var.horario_shutdown

  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  timezone = "E. South America Standard Time"

  notification_settings {
    enabled = false
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

