// deploy resources into lz1 resource group
// contains spoke vnet and some workloads

targetScope = 'resourceGroup'

// param BRANCH string
// param PREFIX string
param REGION string = 'southcentralus'

var RG = 'lz1'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${RG}-${REGION}-vnet-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.1.0/24'
      ]
    }
    subnets: [
      {
        name: '${RG}-${REGION}-snet-01'
        properties: {
          addressPrefix: '10.1.1.0/27'
        }
      }
    ]
  }
}
