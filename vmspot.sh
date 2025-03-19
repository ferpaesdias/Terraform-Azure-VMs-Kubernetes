#!/bin/bash

# Adaptado de: https://stackoverflow.com/questions/73191837/find-cheapest-spot-supported-size-sku-via-az-cli-or-terraform-provider

REGION="southeastasia"

VM_FILTER="sort_by([?(numberOfCores == \`1\` && !contains(name, 'Promo')) && \
(contains(name, 'Standard_DC') || contains(name, 'Standard_DS') || contains(name, 'Standard_Ds')) || \
(contains(name, 'Standard_D') && contains(name, '_v3')) || \
(contains(name, 'Standard_D') && contains(name, '_v4'))], &memoryInMB) | [:9].name"

az vm list-sizes --location ${REGION} --query "$VM_FILTER" -o json > vmspot/sizes_vmspot.json

echo -n 'https://prices.azure.com/api/retail/prices?$filter=serviceName eq "Virtual Machines" and armRegionName eq "' > vmspot/url_vmspot.txt
echo -n ${REGION} >> vmspot/url_vmspot.txt
echo -n '" and contains(skuName, "Spot") eq true' >> vmspot/url_vmspot.txt

jq -re '[.[] | "(armSkuName eq \"" + . + "\")"] | " and (" + join(" or ") + ")"' vmspot/sizes_vmspot.json >> vmspot/url_vmspot.txt

sed -i -e "s/\"/'/g" vmspot/url_vmspot.txt

SKU_SPOT=$(az rest --method get --url "$(cat vmspot/url_vmspot.txt)" --query "sort_by(Items, &unitPrice) | [?unitPrice < \`0.05\`]" | jq '.[0].armSkuName' | base64 -w0)

echo "{\"base64\":\"$SKU_SPOT\"}"
