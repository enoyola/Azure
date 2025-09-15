#Envrionment parameters
param( 

[parameter(Mandatory=$true)] 
[string] $VM_NAME, 
  
[parameter(Mandatory=$true)] 
[string] $RESOURCEGROUP_NAME
) 

filter timestamp {"[$(Get-Date -Format G)]: $_"} 
 
Write-Output "Script started." | timestamp 

$connectionName = "AzureRunAsConnection"
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity -AccountId "Subscription ID"
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$VerbosePreference = 'continue'

$currentSubscription = (Get-AzContext).Subscription
$resourceGroups = Get-AzResourceGroup

Restart-AzVM -ResourceGroupName "$RESOURCEGROUP_NAME" -Name "$VM_NAME"

Write-Output "Script finished." | timestamp