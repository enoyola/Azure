#Envrionment parameters
param( 

[parameter(Mandatory=$true)] 
[string] $DB_NAME, 
 
[parameter(Mandatory=$true)] 
[string] $SQL_INSTANCE_NAME, 
  
[parameter(Mandatory=$true)] 
[string] $RESOURCEGROUP_NAME,

[parameter(Mandatory=$true)] 
[string] $RESTORE_POINT,

[parameter(Mandatory=$true)] 
[string] $DB_TARGET_NAME
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

Restore-AzSqlinstanceDatabase -Name "$DB_NAME" -InstanceName "$SQL_INSTANCE_NAME" -ResourceGroupName "$RESOURCEGROUP_NAME" -PointInTime "$RESTORE_POINT" -TargetInstanceDatabaseName "$DB_TARGET_NAME” -FromPointInTimeBackup

Write-Output "Script finished." | timestamp