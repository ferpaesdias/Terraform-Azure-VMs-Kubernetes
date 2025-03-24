locals {
  kube_config = <<CUSTOM_DATA
#!/bin/env bash

a=0
while [ $a -eq 0 ]
do
    ssh -o StrictHostKeyChecking=no -i id_rsa -o StrictHostKeyChecking=no adminuser@${azurerm_public_ip.public_ip[1].ip_address} sudo ls /etc/kubernetes/admin.conf > /dev/null 2>&1
      if [[ $? -eq 0 ]]
      then
        KUBECONFIG=$(ssh -o StrictHostKeyChecking=no -i id_rsa -o StrictHostKeyChecking=no adminuser@${azurerm_public_ip.public_ip[1].ip_address} sudo cat /etc/kubernetes/admin.conf | base64 -w0)
        a=1
      fi
    sleep 1
done

echo "{\"base64\":\"$KUBECONFIG\"}"
CUSTOM_DATA
}

resource "local_file" "kubeconfig_sh" {
  content         = local.kube_config
  filename        = "kubeconfig.sh"
  file_permission = "0755"
}

