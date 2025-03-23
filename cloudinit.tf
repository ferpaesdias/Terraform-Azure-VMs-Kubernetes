locals {
  custom_data = <<CUSTOM_DATA
#!/bin/env bash

# Ajuste Timezone
sudo timedatectl set-timezone ${var.timezone_vms}

# Instalação de utilitários 
sudo apt update 
sudo apt install -y apt-transport-https build-essential ca-certificates curl gpg jq lsb-release python3-pip software-properties-common tree unzip gnupg bash-completion

# Configuração dos módulos do Node
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configurar parâmetros do sistema
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Adiciona uma entrada do Node1 no Hosts dos Nodes
cat <<-EOF | sudo tee -a /etc/hosts
172.16.2.11 node1
EOF

# Instalação do Kubeadm, Kubectl e Kubelet
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# kubectl - configuração do completion e do alias no bash
sudo echo 'source <(kubectl completion bash)' >> /home/adminuser/.bashrc
sudo echo 'alias k="kubectl"' >> /home/adminuser/.bashrc

# Instalação do containerd  
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update 
sudo apt install -y containerd.io 
 

# Configurar o containerd, alterar a opção SystemdCgroup para true
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd


# Habilitar o serviço do kubelet
sudo systemctl enable --now kubelet


# Usar para o Kubeadm init
if [ "$HOSTNAME" == "node1" ]
  then
    PUBLIC_IP=$(curl --silent https://ifconfig.me)
    kubeadm init --control-plane-endpoint $PUBLIC_IP --apiserver-cert-extra-sans=172.16.2.11,$PUBLIC_IP --ignore-preflight-errors=DirAvailable--var-lib-etcd,NumCPU
    mkdir -p /home/adminuser/.kube
    sudo cp -i /etc/kubernetes/admin.conf /home/adminuser/.kube/config
    sudo chown adminuser:adminuser /home/adminuser/.kube/config
    sudo kubeadm token create --print-join-command > /tmp/kubetoken
fi

# Adiciona um node diferente do Node1 ao Control Plane
if [ "$HOSTNAME" != "node1" ]
then
  # Private key do SSH
  echo "${tls_private_key.ssh.private_key_pem}" > /home/adminuser/.ssh/id_rsa
  sudo chown adminuser:adminuser /home/adminuser/.ssh/id_rsa
  sudo chmod 0600 /home/adminuser/.ssh/id_rsa

  # Adiciona Node (Worker) ao Control Plane
  a=0
  while [ $a -eq 0 ]
  do
    scp -C -i /home/adminuser/.ssh/id_rsa -o StrictHostKeyChecking=no adminuser@node1:/tmp/kubetoken /tmp/kubetoken 
      if [[ $? -eq 0 ]]
      then
        sudo /bin/bash /tmp/kubetoken
        a=1
      fi
    sleep 1
  done
fi

# Instalação do Helm e do Cilium (CNI - Container Network Interface) no Node1
if [ "$HOSTNAME" == "node1" ]
  then
    sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    sudo chmod 700 get_helm.sh
    sudo /bin/bash /get_helm.sh

    su -c "helm repo add cilium https://helm.cilium.io/" -s /bin/bash adminuser 
    su -c "helm install cilium cilium/cilium --version 1.17.2 --namespace kube-system" -s /bin/bash adminuser
fi
CUSTOM_DATA
}

