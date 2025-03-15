locals {
  nodes = {
    for i in range(1, 1 + var.qts_vms) :
    i => {
      node_name = format("node%d", i)
    }
  }
}

locals {
  kube = {
    for i in range(2, 1 + var.qts_vms) :
    i => {
      kube_token = format("%d", i)
    }
  }
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

locals {
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
  private_key     = [chomp(tls_private_key.ssh.private_key_pem)]
}
