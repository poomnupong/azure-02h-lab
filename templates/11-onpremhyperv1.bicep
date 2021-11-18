// deploy resources into onpremhyperv1 resource group

targetScope = 'resourceGroup'

param PREFIX string
param REGION string = 'southcentralus'

var RG = 'bootstrap1'

// hyperv-host for on-prem simulation



