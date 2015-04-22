# Cloudera Template

To support nested templates, I've had to upload some files an Azure Blob Storage instance.  These templates are currently tied to my MSDN account.  This will change as we move along.

## Deployment

Currently manual changes to the templates to choose the correct blob storage are needed.

To deploy via PowerShell run

New-AzureResourceGroup -Name Test -DeploymentName TestDeploy -Location "West US" -TemplateFile .\azuredeploy.json

## IP Address Allocation

.9 - Management Node
.10 - 19  - Name Nodes
.20 - 254 - Data Nodes
