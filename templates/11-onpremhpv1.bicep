// deploy resources into onpremhyperv1 resource group
// contains hyper-v host for nested workload to simulate on-prem

targetScope = 'resourceGroup'

param BRANCH string
param PREFIX string
//param REGION string = 'southcentralus'
//var RG = 'onpremhpv1'

// hyperv-host for on-prem simulation
// D4s_v3 - works - original
// D4s-v4 - ?
// D4s-v5 - not available in scus as of 2021.11.18
// D4as_v4 - doesn't work
param virtualMachineSize string = 'Standard_D4s_v3'
param adminUsername string = 'user01'

@secure()
param adminPassword string
param storageAccountType string = 'Premium_LRS'
param location string = resourceGroup().location

var virtualMachineName = 'onprem1-vm'
var nic1Name = '${virtualMachineName}-nic1'
var nic2Name = '${virtualMachineName}-nic2'
var publicIPAddressName = '${virtualMachineName}-pip1'
// var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
// var networkSecurityGroupName = '${virtualMachineName}-nsg1'

// VM for nested hyper-v
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
        name: '${virtualMachineName}-OsDisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
        caching: 'ReadWrite'
      }
      dataDisks: [
        {
          lun: 0
          name: '${virtualMachineName}-DataDisk1'
          createOption: 'Empty'
          diskSizeGB: 512
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: storageAccountType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
        {
          id: nic2.id
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

/* ### not doing managed diag storage for now
resource diagsAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: diagStorageAccountName
  location: resourceGroup().location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}
*/

// pick up existing vnet1 from bootstrap1
resource vnet1 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: 'bootstrap1-southcentralus-vnet-01'
  scope: resourceGroup('${PREFIX}-${BRANCH}-bootstrap1-southcentralus-rg')
}

// This will be your Primary NIC - for VM access
resource nic1 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nic1Name
  location: resourceGroup().location
  properties: {
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet1.id}/subnets/bootstrap1-southcentralus-snet-01'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip1.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg1.id
    }
  }
}

// This will be your Primary NIC - for NAT
resource nic2 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nic2Name
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet1.id}/subnets/bootstrap1-southcentralus-snet-02'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: json('null')
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg2.id
    }
  }
}

// Public IP for your Primary NIC
resource pip1 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Network Security Group (NSG) for your Primary NIC
resource nsg1 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${virtualMachineName}-nsg1'
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

// Network Security Group (NSG) for your Primary NIC
resource nsg2 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${virtualMachineName}-nsg2'
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
