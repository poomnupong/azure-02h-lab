$templateFile = "./00maintemplate.json"
$templateParameterFile = "./00maintemplate.parameter.json"
#$rgName = "02hlab-rg"
#$rgLocation = "southcentralus"
New-AzDeployment `
  -Name acideploy-$(Get-Date -f yyyyMMdd_HHmmss) `
  -TemplateUri $templateFile `
  -Location $rgLocation `
  -TemplateParameterFile $templateParameterFile

# -Whatif