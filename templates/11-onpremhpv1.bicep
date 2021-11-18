// deploy resources into onpremhyperv1 resource group

targetScope = 'resourceGroup'

param BRANCH string
param PREFIX string
param REGION string = 'southcentralus'

var RG = 'bootstrap1'

// hyperv-host for on-prem simulation

param virtualMachineSize string = 'Standard_D4as_v4'
param adminUsername string

@secure()
param adminPassword string
param storageAccountType string = 'Standard_LRS'
param location string = resourceGroup().location

var virtualMachineName = 'test01-vm'
var nic1Name = '${virtualMachineName}nic1'
var publicIPAddressName = '${virtualMachineName}-pip1'
var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = '${virtualMachineName}-nsg1'

// This is the virtual machine that you're building.
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineName
  location: resourceGroup().location
  properties: {
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    licenseType: 'Windows_Server'
    priority: 'Spot'
    evictionPolicy: 'Deallocate'
    billingProfile: {
      maxPrice: -1
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        //storageUri: diagsAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource diagsAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: diagStorageAccountName
  location: resourceGroup().location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

// This will build a Virtual Network.
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: 'bootstrap1-southcentralus-vnet-01'
  scope: resourceGroup('02h-${BRANCH}-bootstrap1-southcentralus-rg')
}

// This will be your Primary NIC
resource nic1 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nic1Name
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/bootstrap1-southcentralus-snet-01'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Public IP for your Primary NIC
resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Network Security Group (NSG) for your Primary NIC
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-rdp-poomlab'
        properties: {
          priority: 1000
          sourceAddressPrefix: '76.184.207.222'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

output publicIp string = pip.properties.ipAddress
