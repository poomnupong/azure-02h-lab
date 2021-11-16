// deploy all necessary resource groups

targetScope = 'subscription'

param BRANCH string
param REGION string = 'southcentralus'

// specify all resource group names here in array so we can loop through them
var RG_ARRAY = [
  '${BRANCH}-launchpad-${REGION}-rg'
  '${BRANCH}-conn1-${REGION}-rg'
  '${BRANCH}-onpremhyperv1-${REGION}-rg'
  '${BRANCH}-lz1-${REGION}-rg'
]

// 
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for RG_NAME in RG_ARRAY: {
  name: RG_NAME
  location: REGION
  tags:{
    'branch': BRANCH  
  }
}]
