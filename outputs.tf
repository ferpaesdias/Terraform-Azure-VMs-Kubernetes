output "Dados_VMS" {
  value = format(
    "\nTamanho das VMs = %s \nPreço por hora (dólar) = US$ %s ",
      trimspace(replace(base64decode(data.external.vmspot.result.size), "\"", "")), 
      trimspace(replace(base64decode(data.external.vmspot.result.price), "\"", ""))
  ) 
}

output "Acesso_SSH" {
  value = join(
    "\n",
    [for i in azurerm_linux_virtual_machine.vm :
      format(
        "VM = %s | ssh -o StrictHostKeyChecking=no -l adminuser -p 22 -i id_rsa %s",
        i.name, 
        i.public_ip_address,
      )
    ]
  )
}