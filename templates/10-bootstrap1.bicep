// deploy resources into bootstrap1 resource group

targetScope = 'resourceGroup'

// param BRANCH string
param PREFIX string
param REGION string = 'southcentralus'

var RG = 'bootstrap1'

// main key vault for bootstrap
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'k-${PREFIX}${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    accessPolicies: [
      {
        tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
        objectId: 'ba2dcfeb-5adb-40bf-b47c-5cb4bbb0d6c8'
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
  }
}

// main log analytics workspace for everything
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${RG}-${REGION}-law-01'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standalone'
    }
  }
}

// main vnet for everything in bootstrap1
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${RG}-${REGION}-vnet-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: '${RG}-${REGION}-snet-01'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      {
        name: '${RG}-${REGION}-snet-02'
        properties: {
          addressPrefix: '10.0.0.32/27'
        }
      }
    ]
  }
}
