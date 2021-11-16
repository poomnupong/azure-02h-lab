targetScope = 'subscription'

param BRANCH string
param RG_NAME string
param LOCATION string = 'southcentralus'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG_NAME
  location: LOCATION
  tags:{
    'branch': BRANCH  
  }
}
