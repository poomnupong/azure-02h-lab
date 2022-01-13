// deploy control workstation into bootstrap1 vnet in labconsole-rg
// contains a linux VM for controlling lab

targetScope = 'resourceGroup'

param BRANCH string
param PREFIX string
param REGION string = 'southcentralus'
// var RG = 'labconsole'

// hyperv-host for on-prem simulation
// D4s_v3 - works - original
// D4s-v4 - ?
// D4s-v5 - not available in scus as of 2021.11.18
// D4as_v4 - doesn't work
param virtualMachineSize string = 'Standard_D2s_v4'
param adminUsername string = 'admin01'

// @secure()
param adminPassword string
param storageAccountType string = 'Premium_LRS'
param location string = resourceGroup().location

var virtualMachineName = 'labconsole-vm1'
var nic1Name = '${virtualMachineName}-nic1'
var publicIPAddressName = '${virtualMachineName}-pip1'
// var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = '${virtualMachineName}-nsg1'

// === end variable declaration ===

// pick up existing vnet from bootstrap1
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: 'bootstrap1-${REGION}-vnet-01'
  scope: resourceGroup('${PREFIX}-${BRANCH}-bootstrap1-${REGION}-rg')
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
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYoZVx0A4DL+vmGAKaSFhi5Wx7XVVZPmnrNw0ht/dQ6aDrg5heHOXgeObK1x+ljgX/n5wqgPy4dHaavtTpRSrs3V6jGszzldI6XjzkwvR1vNoj6YBoATLxLaD85a/CM+W0Xd8oxxzW8qMbLKV/lyZ1xGjuvt8mqe1DqKapd+AXuUqB40Tn2zzYwo96fKQBwPproLuanJYQspEG9jZ1qUxY7ABNtIDogOpOwLtJOnnUbHf3SwH6EC6z6IsScOaPb+KEh/VKv7wbiEjMVCYLj8W0hLnux8M+TB7QnJnvWfvo/yncOsImPvB0//9muO4PSqCqmyAU9kNWeuZBjR719MG/ySpfttU4BR/sKgk+Bmk5cDxyBcPYGtk77KRP87mu3kqlQ0xSqkqffqAJnLwnNthLLoyo7k6wTJH7Ud5N6FT025WTg0++vWAidvQKTzuc3PQq0s208AXtOqvit3AR1azsj5qvcQtQFlnLT5ht8lMZUxUageqdPlVPL0ozlphTCp8yEBdr5jhQUK/XKij159jdAPUz7ajxOCimAZKH88DM71zWxgy9OckBJlBWcQVLPZe+ZjyLY9auZWDVX0jo5GKzaSycSzQ/eoAfA3hdSYGDuHrGJB2/2kvKUYlipGIUQpPDVlAP9d3mIhnM2yaxInA+Q2PGzlhfQFELSHo9yKLebw=='
            }
          ]
        }
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
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
        // === doesn't need it ===
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
        name: 'allow-ssh-poomlab'
        properties: {
          priority: 1000
          sourceAddressPrefix: '76.184.207.222'
          protocol: 'Tcp'
          destinationPortRange: '22'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
