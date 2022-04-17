// deploy resources into bootstrap1 resource group
// contains bootstrap elements of landing zone and also the nested hyper-v

targetScope = 'resourceGroup'

// param BRANCH string
param PREFIX string
param REGION string = 'southcentralus'

var RG = 'bootstrap1'

// main key vault for bootstrap
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'k-${PREFIX}${uniqueString(resourceGroup().id)}'
  location: REGION
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
  name: '${RG}-${REGION}-law1'
  location: REGION
  properties: {
    sku: {
      name: 'Standalone'
    }
  }
}

// main vnet for everything in bootstrap1
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${RG}-${REGION}-vnet1'
  location: REGION
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: '${RG}-${REGION}-snet1'
        properties: {
          addressPrefix: '10.0.0.0/27'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: '${RG}-${REGION}-snet2'
        properties: {
          addressPrefix: '10.0.0.32/27'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Network Security Group (NSG) for the vnet
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${RG}-${REGION}-vnet01-nsg1'
  location: REGION
  properties: {
    securityRules: [
      // {
      //   name: 'allow-ssh-poomlab'
      //   properties: {
      //     priority: 1000
      //     sourceAddressPrefix: '76.184.207.222'
      //     protocol: 'Tcp'
      //     destinationPortRange: '22'
      //     access: 'Allow'
      //     direction: 'Inbound'
      //     sourcePortRange: '*'
      //     destinationAddressPrefix: '*'
      //   }
      // }
    ]
  }
}
