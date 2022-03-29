// deploy all necessary resource groups

targetScope = 'subscription'

param PREFIX string = 'dummy'
param BRANCH string
param REGION string = 'southcentralus'

// specify all resource group names here in array so we can loop through them a
var RG_ARRAY = [
  '${PREFIX}-${BRANCH}-bootstrap1-${REGION}-rg'
  '${PREFIX}-${BRANCH}-onpremhpv1-${REGION}-rg'
  '${PREFIX}-${BRANCH}-labconsole1-${REGION}-rg'
  '${PREFIX}-${BRANCH}-conn1-${REGION}-rg'
  '${PREFIX}-${BRANCH}-lz1-${REGION}-rg'
  '${PREFIX}-${BRANCH}-lz2-${REGION}-rg'
  '${PREFIX}-${BRANCH}-lz3-${REGION}-rg'
]

// create all resource groups through loop
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for RG_NAME in RG_ARRAY: {
  name: RG_NAME
  location: REGION
  tags:{
    'branch': BRANCH  
  }
}]
