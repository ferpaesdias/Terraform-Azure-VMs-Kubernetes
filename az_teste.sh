#!/bin/bash

# curl --silent 'https://prices.azure.com/api/retail/prices?$filter=serviceName%20eq%20%27Virtual%20Machines%27and%20armRegionName%20eq%20%27eastus2%27%20and%20contains(meterName%2C%20%27Spot%27)&$orderby=unitPrice%20asc&top=0' | jq


#  query = "armRegionName eq 'southcentralus' and armSkuName eq 'Standard_NP20s' and priceType eq 'Consumption' and contains(meterName, 'Spot')"  and ne contains(armSkuName, 'Standard_B')


# curl --silent 'https://prices.azure.com/api/retail/prices?$filter=serviceName%20eq%20%27Virtual%20Machines%27and%20armRegionName%20eq%20%27eastus2%27%20and%20contains(meterName%2C%20%27Spot%27)%20and%20(contains(armSkuName%2C%20%27Promo%27)%20eq%20false%20and%20contains(armSkuName%2C%20%27Standard_B%27)%20eq%20false)&$orderby=unitPrice%20asc&$top=-997' | jq


curl --silent 'https://prices.azure.com/api/retail/prices?%24filter=serviceName%20eq%20%27Virtual%20Machines%27and%20armRegionName%20eq%20%27eastus2%27%20and%20contains(meterName%2C%20%27Spot%27)%0A%20and%20(contains(armSkuName%2C%20%27Promo%27)%20eq%20false%20and%20contains(armSkuName%2C%20%27Standard_B%27)%20eq%20false)&%24orderby=unitPrice%20asc&%24top=3'  \
| jq  .Items.armSkuName 