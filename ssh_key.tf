# Cria as chaves de autenticação do SSH
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "id_rsa.pub"
  file_permission = "0600"
}

# Dados das chaves do SSH
locals {
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
  private_key     = [chomp(tls_private_key.ssh.private_key_pem)]
}