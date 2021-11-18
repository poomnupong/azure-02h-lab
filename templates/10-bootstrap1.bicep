// deploy resources into bootstrap1 resource group

targetScope = 'resourceGroup'

/* may not need these
param PREFIX string = 'dummy'
param BRANCH string
param REGION string = 'southcentralus'
*/

var REGION_ABBR = 'scus'
var RG string = 'bootstrap1'
// var PROJECT_NAME string = '${PREFIX}-${RG}'

// main keyvault for bootstrap
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${RG}-${REGION_ABBR}-kv-01'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    /*
    tenantId: 'tenantId'
    accessPolicies: [
      {
        tenantId: 'tenantId'
        objectId: 'objectId'
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
    */
  }
}

// main log analytics workspace for everything
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${RG}-${REGION_ABBR}-law-01'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

// main vnet for everything in bootstrap1
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${RG}-${REGION_ABBR}-vnet-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: '${RG}-${REGION_ABBR}-snet-01'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      {
        name: '${RG}-${REGION_ABBR}-snet-02'
        properties: {
          addressPrefix: '10.0.32.0/27'
        }
      }
    ]
  }
}
