#Envrionment parameters
param( 

[parameter(Mandatory=$true)] 
[string] $VM_NAME, 
  
[parameter(Mandatory=$true)] 
[string] $RESOURCEGROUP_NAME,

[parameter(Mandatory=$true)] 
[string] $VAULT_NAME
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

$vault = Get-AzRecoveryServicesVault -ResourceGroupName "$RESOURCEGROUP_NAME" -Name "$VAULT_NAME"
$NamedContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName "$VM_NAME" -VaultId $vault.ID
$Item = Get-AzRecoveryServicesBackupItem -Container $NamedContainer -WorkloadType AzureVM -VaultId $vault.ID
$Job = Backup-AzRecoveryServicesBackupItem -Item $Item -VaultId $vault.ID
$Job
