#Envrionment parameters
param( 

[parameter(Mandatory=$true)] 
[string] $resourceGroupName, 
 
[parameter(Mandatory=$true)] 
[string] $serverName, 
  
 
[parameter(Mandatory=$true)] 
[string] $action
) 
 
filter timestamp {"[$(Get-Date -Format G)]: $_"} 
 
Write-Output "Script started." | timestamp 
 
#$VerbosePreference = "Continue" ##enable this for verbose logging
$ErrorActionPreference = "Stop" 
 
#Authenticate with Azure Identity 
$connectionName = "AzureRunAsConnection"
try
{
    "Logging in to Azure..."
    Connect-AzAccoun -Identity -AccountId "Subscription ID"
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$VerbosePreference = 'continue'

$currentSubscription = (Get-AzContext).Subscription
 
$startTime = Get-Date 
Write-Output "Azure Automation local time: $startTime." | timestamp 

# Get the authentication token 
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}
Write-Output "Authentication Token acquired." | timestamp 

##Invoke REST API Call based on specified action

if($action -eq 'stop')
{

        # Invoke the REST API
        $restUri='https://management.azure.com/subscriptions/'+$azContext.Subscription.Id+'/resourceGroups/'+$resourceGroupName+'/providers/Microsoft.DBforMySQL/flexibleServers/'+$serverName+'/'+$action+'?api-version=2023-12-30'
        $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
        Write-Output "$servername is getting stopped." | timestamp 
}
else
{
        # Invoke the REST API
        $restUri='https://management.azure.com/subscriptions/'+$azContext.Subscription.Id+'/resourceGroups/'+$resourceGroupName+'/providers/Microsoft.DBforMySQL/flexibleServers/'+$serverName+'/'+$action+'?api-version=2023-12-30'
        $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
        Write-Output "$servername is Starting." | timestamp 
 }

Write-Output "Script finished." | timestamp