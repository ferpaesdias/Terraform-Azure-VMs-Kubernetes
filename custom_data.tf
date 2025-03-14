locals {
  custom_data = <<CUSTOM_DATA
package_upgrade: true
packages: 
  - apt-transport-https
  - build-essential
  - ca-certificates
  - containerd.io
  - curl
  - docker-ce
  - gpg
  - jq
  - kubeadm
  - kubectl
  - kubelet
  - lsb-release
  - make
  - prometheus-node-exporter
  - python3-pip
  - software-properties-common
  - tree
  - unzip
  - nmap




  CUSTOM_DATA
}

