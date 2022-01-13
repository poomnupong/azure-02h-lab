// deploy resources into lz1 resource group
// contains spoke vnet and some workloads

targetScope = 'resourceGroup'

var RG = 'lz1'
// param BRANCH string
// param PREFIX string
param REGION string = 'southcentralus'
param virtualMachineSize string = 'Standard_F1s'

param adminUsername string = 'admin01'
@secure()
param adminPassword string
param storageAccountType string = 'Premium_LRS'
param location string = resourceGroup().location

var virtualMachineName = '${RG}-${REGION}-vm-01'
var nic1Name = '${virtualMachineName}-nic1'
// var publicIPAddressName = '${virtualMachineName}-pip1'
// var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = '${virtualMachineName}-nsg1'

// main vnet
resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
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

// small VM for simple tests
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineName
  location: resourceGroup().location
  properties: {
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    // licenseType: 'Windows_Server'
    priority: 'Spot'
    evictionPolicy: 'Deallocate'
    billingProfile: {
      maxPrice: -1
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachineName}-OsDisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
        caching: 'ReadWrite'
      }
      dataDisks: [
        // {
        //   lun: 0
        //   name: '${virtualMachineName}-DataDisk1'
        //   createOption: 'Empty'
        //   diskSizeGB: 1024
        //   caching: 'ReadOnly'
        //   managedDisk: {
        //     storageAccountType: storageAccountType
        //   }
        // }
      ]
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
            id: '${vnet.id}/subnets/${RG}-${REGION}-snet-01'
          }
          privateIPAllocationMethod: 'Dynamic'
          // publicIPAddress: {
          //   id: pip.id
          // }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// // Public IP for your Primary NIC
// resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
//   name: publicIPAddressName
//   location: location
//   properties: {
//     publicIPAllocationMethod: 'Dynamic'
//   }
// }

// Network Security Group (NSG) for your Primary NIC
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      // {
      //   name: 'allow-rdp-poomlab'
      //   properties: {
      //     priority: 1000
      //     sourceAddressPrefix: '76.184.207.222'
      //     protocol: 'Tcp'
      //     destinationPortRange: '3389'
      //     access: 'Allow'
      //     direction: 'Inbound'
      //     sourcePortRange: '*'
      //     destinationAddressPrefix: '*'
      //   }
      // }
    ]
  }
}

