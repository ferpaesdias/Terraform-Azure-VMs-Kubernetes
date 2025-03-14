# Criar Resource Group
resource "azurerm_resource_group" "k8s_vms" {
  name     = "K8S_VMs"
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
  admin_username        = "adminuser"
  custom_data           = filebase64("${path.module}/cloudinit.yaml")
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

# # Executa o script custom_data.sh
# resource "azurerm_virtual_machine_run_command" "custom_data" {
#   depends_on         = [azurerm_linux_virtual_machine.vm, ]
#   for_each           = local.nodes
#   name               = "custom_data"
#   location           = azurerm_resource_group.k8s_vms.location
#   virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
#   source {
#     script = "sudo /bin/bash /etc/customdata"
#   }
# }

# # Comando que cria o token para os Workers
# resource "azurerm_virtual_machine_run_command" "kubeadm_token" {
#   depends_on         = [azurerm_virtual_machine_run_command.custom_data, ]
#   name               = "kubeadm_token"
#   location           = azurerm_resource_group.k8s_vms.location
#   virtual_machine_id = azurerm_linux_virtual_machine.vm[1].id
#   source {
#     script = "sudo kubeadm token create --print-join-command > /kubetoken"
#   }
# }

# data "external" "id_rsa" {
#   for_each   = local.kube
#   depends_on = [azurerm_virtual_machine_run_command.custom_data, ]
#   program    = [
#     "bash", 
#     "-c",
#     <<-EOT
#       set -e
#       kubeadm token create --print-join-command
#     EOT
#   ]
# }


# # Comando que cria o token para os Workers
# resource "azurerm_virtual_machine_run_command" "kubeadm_token" {
#   for_each           = local.kube
#   depends_on         = [azurerm_virtual_machine_run_command.custom_data, ]
#   name               = "kubeadm_token"
#   location           = azurerm_resource_group.k8s_vms.location
#   virtual_machine_id = azurerm_linux_virtual_machine.vm[each.value.kube_token].id
#   source {
#     script = "sudo chmod 0600 /id_rsa && export kubetoken=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l adminuser -p 22 -i /id_rsa ${azurerm_linux_virtual_machine.vm[1].public_ip_address} kubeadm token create) && sudo $kubetoken && exit"
#   }
# }
