output "Dados_VMS" {
  value = format(
    "\tTamanho de cada VM = %s \n\tPreço por hora de cada VM = US$ %s ",
      trimspace(replace(base64decode(data.external.vmspot.result.size), "\"", "")), 
      trimspace(replace(base64decode(data.external.vmspot.result.price), "\"", ""))
  ) 
}

output "Acesso_SSH" {
  value = join(
    "\n",
    [for i in azurerm_linux_virtual_machine.vm :
      format(
        "\tVM = %s | ssh -o StrictHostKeyChecking=no -l adminuser -p 22 -i id_rsa %s",
        i.name, 
        i.public_ip_address,
      )
    ]
  )
}

output "DNS" {
  value = join(
    "\n",
    [for i in azurerm_public_ip.public_ip :
      format(
        "\t%s",
        i.fqdn
      )
    ]
  )
}

output "kubeconfig" {
  value = "\tPara acessar o cluster do kubectl de sua máquina execute o comando abaixo:\n\texport KUBECONFIG=$PWD/kubeconfig"
}

