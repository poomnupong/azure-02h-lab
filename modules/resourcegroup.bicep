targetScope = 'subscription'

param BRANCH string
param RG_NAME string
param REGION string = 'southcentralus'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG_NAME
  location: REGION
  tags:{
    'branch': BRANCH  
  }
}
