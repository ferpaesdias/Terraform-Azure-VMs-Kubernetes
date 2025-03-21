#!/bin/env bash

# Script que seleciona um tamanho de VM Spot

# Adaptado de: https://stackoverflow.com/questions/73191837/find-cheapest-spot-supported-size-sku-via-az-cli-or-terraform-provider

# Escolha a região, o número de vCPUs (Cores) e a quantidade de memória em MB das VMs
REGION="eastus2"  
NUMBER_CORES="2"
MEMORY_MB="2048"

# Valor máximo, por hora, da VM (em dólares).
VM_VALUE="0.05"

# Faz a filtragem para escolher somente VMs com da região, números de vCPU (Cores), memória pré-determindos nas variáveis acima.
# Também filtra somente VMs compatíveis com a versão Gen 2 do Hypervisor.
# Não alterar está variável.
VM_FILTER="\
reverse( \
    sort_by( \
                [? \
                    ( \
                        (numberOfCores == \`${NUMBER_CORES}\` && (memoryInMB >= \`${MEMORY_MB}\`) && (!contains(name, 'Promo') && !contains(name, 'p'))) && \
                        (
                            (contains(name, 'Standard_DC') || contains(name, 'Standard_DS') || contains(name, 'Standard_Ds')) || 
                            (contains(name, 'Standard_D') && contains(name, '_v3')) || \
                            (contains(name, 'Standard_D') && contains(name, '_v4')) \
                        ) \
                    ) \
                ], &memoryInMB \
            ) \
        ) \
| [:9].name"

# Consulta os tamanhos das VMs Spot disponíveis no Azure
az vm list-sizes --location ${REGION} --query "$VM_FILTER" -o json > vmspot/sizes_vmspot.json

# Os comandos abaixo fazem a consulta e filtros para buscar o tamanho da image
echo -n 'https://prices.azure.com/api/retail/prices?$filter=serviceName eq "Virtual Machines" and armRegionName eq "' > vmspot/url_vmspot.txt
echo -n ${REGION} >> vmspot/url_vmspot.txt
echo -n '" and contains(skuName, "Spot") eq true' >> vmspot/url_vmspot.txt
jq -re '[.[] | "(armSkuName eq \"" + . + "\")"] | " and (" + join(" or ") + ")"' vmspot/sizes_vmspot.json >> vmspot/url_vmspot.txt
sed -i -e "s/\"/'/g" vmspot/url_vmspot.txt


SKU_SPOT=$(az rest --method get --url "$(cat vmspot/url_vmspot.txt)" --query "sort_by(Items, &unitPrice) | [?unitPrice < \`${VM_VALUE}\`]" | jq '.[0].armSkuName' | base64 -w0)

echo "{\"base64\":\"${SKU_SPOT}\"}"
