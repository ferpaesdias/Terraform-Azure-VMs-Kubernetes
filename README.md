# Terraform-Azure-VMs-Kubernetes

<br>

## Motivação

Sou aluno dos cursos PICK (Programa Intensivo em Containers e Kubernetes) e Descomplicando o Terraform da [Linux Tips](https://linuxtips.io/).  

Depois de assistir a este vídeo [CRIE SEU CLUSTER KUBERNETES NO CLOUD AGORA E GRATUITAMENTE! é sério!](https://www.youtube.com/watch?v=c5qUOtB3fxo) do [Jefferson](https://www.linkedin.com/in/jefersonfernando/), eu decidi criar um ambiente similar no Microsoft Azure. Embora, o ambiente não seja gratuito, será criado com o menor custo possível.

O código abaixo foi inspirado no repositório [ampernetacle](https://github.com/jpetazzo/ampernetacle), citado no vídeo acima, do [Jérôme Petazzoni](https://www.linkedin.com/in/jpetazzo/).

<br>

## Objetivo

Está configuração do Terraform tem como objetivo criar no Microsoft Azure um ambiente para o estudo de Kubernetes com um custo mínimo.  
Para ambiente em produção recomendo utilizar o [AKS](https://learn.microsoft.com/pt-br/azure/aks/what-is-aks).

<br>


## Configuração padrão

O ambiente padrão será criado dentro do Resource Group `K8S_VMs`, na localização `East US 2` e é composto de 03 VMs sendo uma o Control Plane e as outras duas Workers.

As VMs são do tipo `spot`, possuem 02 vCPUs e, no mínimo, 02 GB de RAM. Os discos são do tipo HDD.

As VMs serão nomeadas como `node1`, `node2`, `node3` e, assim por diante.  

Os endereços IPs privados da VMs começam com `172.16.2.11/24` na VM `node1` e seguem em sequencia nos demais nodes.  

Todas as VMs receberão um endereço IP público e um acesso via SSH usando chaves públicas e privadas.

As VMs utilizarão o sistema Operacional `Debian 12`, serão do tipo "Spot" e serão configuradas com o Timezone `America/Sao_Paulo`.

Para diminuir custos (esquecer as VMs ligadas de madrugada, por exemplo), as VMs estarão com a opção `Auto-Shutdown` habilitada. O `Auto-Shutdown` será configurado para desligar (desalocar) as VMs às `20:30` (horário de Brasília).

Será instalado o Kubernetes na versão `1.32` e o CNI (Container Network Interface) [Cilium](https://docs.cilium.io/en/stable/).

<br>

## Principais pontos

- O script `vmspot.sh` pesquisa no MS Azure por uma VM `spot`, que tenha a quantidade de vCPUs e memória pré-definidos e que custe menos de U$ 0,05.
- A quantidade de Nodes pode ser definida em `variables.tf`.
- Este ambiente utiliza somente famílias de [VMs compatíveis com o Hypervisor Gen 2](https://learn.microsoft.com/pt-br/azure/virtual-machines/generation-2).
- No MS Azure, cada Subscription tem uma quota de uso de vCPU spot. Se precisar aumentar a quota de vCPU spot veja esta [documentação](https://learn.microsoft.com/pt-br/azure/quotas/spot-quota) do Azure.
- Por ser um ambiente de estudo, todo o tráfego de entrada e saída é liberado.
- A troca da localização das VMs deve ser realizada nos arquivos `variables.tf` e `vmspot.sh`.
- No arquivo `variables.tf` também é possível alterar o horário do `Auto-Shutdown` ou desativá-lo.
- `services` do tipo `LoadBalancer` ficarão com o campo `External-IP` como `pending`. Para expor um serviço crie um `service` do tipo `NodePort`.
- No diretório do Terraform serão criados os seguintes arquivos:

    - `id_rsa`: Chave privada do acesso SSH.
    - `id_rsa.pub`: Chave pública do acesso SSH.
    - `kubeconfig`: Arquivo ao qual poderá ser utilizado pelo `kubectl` de sua máquina local para acessar o cluster.
    - `vmspot`: Diretório do script `vmspot.sh` e dos arquivos criados por este script.

<br>

## Pré-requisitos e criação do ambiente

- Ter o [Terraform instalado](https://developer.hashicorp.com/terraform/install).
- Ter o [Azure CLI instalado](https://learn.microsoft.com/pt-br/cli/azure/what-is-azure-cli).
- Ter o [Kubectl instalado](https://kubernetes.io/docs/tasks/tools/).
- Ter o programa `jq` instalado: `sudo apt install jq`.

<br>

> [!NOTE]
> Só utilizei o Terraform em máquina local com o Sistema Operacional Linux baseado em Debian.  
> Adapte se for utilizar Windows ou MAC.

<br>

### Configuração do AZ CLI

O Terraform precisa saber em qual Subscription você vai criar o ambiente. Existe várias [formas de definir a Subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) que será utilizada. Nós vamos definir a Subscription usando a variável `ARM_SUBSCRIPTION_ID`.  

<br>

Faça o login no Azure CLI
```azurecli
az login
```
Será aberto uma página navegador solicitando login.

<br>

Faça uma lista de suas Subscriptions:
```azurecli
az account list --output table
```

<br>

A saída do comando será parecida com está:
```
Name           CloudName    SubscriptionId                        TenantId                              State    IsDefault
-------------  -----------  ------------------------------------  ------------------------------------  -------  -----------
Pago pelo Uso  AzureCloud   xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy  Enabled  True
```

<br>


Exporte a variável `ARM_SUBSCRIPTION_ID` com o ID da Subscription que deseja utilizar:

```shell
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

<br>

### Clone do Git

Faça o clone deste repositório na sua máquina:

```git
git clone https://github.com/ferpaesdias/Terraform-Azure-VMs-Kubernetes.git
```

<br>

Acesse o diretório do repositório:

```git
cd Terraform-Azure-VMs-Kubernetes
```

<br>

### Criação do ambiente


Inicialize o Terraform:

```shell
terraform init -upgrade
```

<br>

Exporte a variável `ARM_SUBSCRIPTION_ID`:

```shell
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

<br>

Crie um Terraform Plan. O comando abaixo criará um Plan de nome `tfplan_k8s_vms`:

```shell
terraform plan -out tfplan_k8s_vms
```

<br>

Aplique a configuração do Plan `tfplan_k8s_vms`:

```shell
terraform apply tfplan_k8s_vms
```
Quando terminar a execução do `Terraform apply` será exibido o acesso SSH das VMs e o custo, em dólar, por hora de cada VM.  
Mesmo depois que a execução do `Terraform apply` estiver finalizada, aguarde alguns minutos para concluir a instalação dos programas nas VMs.

<br>

Exporte o conteúdo do arquivo de configuração `kubeconfig` para a variável `KUBECONFIG` e assim poder gerenciar o cluster usando o Kubectl de sua máquina:

```shell
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes
```

<br>


Quando terminar de usar o ambiente você pode destruí-lo para não ter gastos desnecessários:

```shell
terraform destroy
```

<br>

> [!NOTE]
> Ao destruir o ambiente todos os dados serão apagados.
