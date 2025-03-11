output "dados_vms" {
  value = join(
    "\n",
    [for i in azurerm_linux_virtual_machine.vm :
      format(
        "VM = %s | VM Size = %s | Public IP = %s",
        i.name,
        i.size,
        i.public_ip_address
      )
    ]
  )
}