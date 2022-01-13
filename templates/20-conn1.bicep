// deploy resources into conn1 resource group
// contains hub vnet and connectivity-related elements

targetScope = 'resourceGroup'

// param BRANCH string
// param PREFIX string
param REGION string = 'southcentralus'
var RG = 'conn1'

// main vnet for everything in bootstrap1
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${RG}-${REGION}-vnet-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.1.0.0/27'
        }
      }
      {
        name: 'AzureGateway'
        properties: {
          addressPrefix: '10.1.0.32/27'
        }
      }
      {
        name: '${RG}-${REGION}-snet-01'
        properties: {
          addressPrefix: '10.1.0.128/27'
        }
      }
    ]
  }
}

// NAT gateway
resource natGateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: '${RG}-${REGION}-natg-01'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natpip1.id
      }
    ]
  }
}

// Public IP for NAT gateway
resource natpip1 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${RG}-${REGION}-natg-pip-01'
  location: resourceGroup().location
  sku:{
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Bastion host
resource bastion1 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: '${RG}-${REGION}-bastion-01'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          // privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastion1pip1.id
          }
          subnet: {
            id: '${virtualNetwork.id}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }

}

// Public IP for NAT gateway
resource bastion1pip1 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${RG}-${REGION}-bastion1-pip-01'
  location: resourceGroup().location
  sku:{
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
