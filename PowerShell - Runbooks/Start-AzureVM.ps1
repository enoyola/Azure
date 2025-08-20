<#
.SYNOPSIS
    Azure Runbook to start a virtual machine
    
.DESCRIPTION
    This runbook connects to Azure using a Managed Identity and starts a specified 
    virtual machine in a given resource group. Designed to run in Azure Automation.
    
.PARAMETER VM_NAME
    The name of the virtual machine to start
    
.PARAMETER RESOURCEGROUP_NAME
    The name of the resource group containing the virtual machine

.PARAMETER MANAGED_IDENTITY_ID
    The ID of the Managed Identity to use for authentication. If not provided,
    the system will attempt to use an environment variable or default managed identity
    
.EXAMPLE
    Start-AzureVM.ps1 -VM_NAME "MyVM" -RESOURCEGROUP_NAME "MyResourceGroup"
    
.EXAMPLE
    Start-AzureVM.ps1 -VM_NAME "MyVM" -RESOURCEGROUP_NAME "MyResourceGroup" -MANAGED_IDENTITY_ID "8d33b784-1241-45d8-a1a7-89bdf6c8df1f"
    
.NOTES
    Author: Eduardo Noyola
    Version: 1.0
    Last Updated: August 19, 2025
    Prerequisites: Azure PowerShell modules, Managed Identity configured
#>

# Define input parameters for the runbook
param( 
    [parameter(Mandatory=$true)] 
    [string] $VM_NAME, 
      
    [parameter(Mandatory=$true)] 
    [string] $RESOURCEGROUP_NAME,
    
    [parameter(Mandatory=$false)]
    [string] $MANAGED_IDENTITY_ID = $null
) 

# Custom filter to add timestamps to output messages
filter timestamp {"[$(Get-Date -Format G)]: $_"} 
 
# Log script start with timestamp
Write-Output "Script started." | timestamp 

try {
    # Determine which managed identity to use
    $identityId = $null
    
    if ($MANAGED_IDENTITY_ID) {
        # Use the managed identity ID provided as parameter
        $identityId = $MANAGED_IDENTITY_ID
        Write-Output "Using Managed Identity from parameter: $identityId" | timestamp
    }
    elseif ($env:AZURE_CLIENT_ID) {
        # Use managed identity ID from environment variable
        $identityId = $env:AZURE_CLIENT_ID
        Write-Output "Using Managed Identity from environment variable: $identityId" | timestamp
    }
    else {
        # Use system-assigned managed identity (no AccountId parameter needed)
        Write-Output "Using system-assigned Managed Identity" | timestamp
    }
    
    # Authenticate to Azure using Managed Identity
    Write-Output "Logging in to Azure using Managed Identity..." | timestamp
    
    if ($identityId) {
        # Connect with specific user-assigned managed identity
        Connect-AzAccount -Identity -AccountId $identityId
    }
    else {
        # Connect with system-assigned managed identity
        Connect-AzAccount -Identity
    }
    
    Write-Output "Successfully connected to Azure." | timestamp
}
catch {
    # Handle authentication errors
    Write-Error -Message "Failed to connect to Azure: $($_.Exception.Message)"
    throw $_.Exception
}

# Enable verbose output for detailed operation logging
$VerbosePreference = 'continue'

# Get current Azure subscription context for logging/verification
$currentSubscription = (Get-AzContext).Subscription
Write-Output "Connected to subscription: $($currentSubscription.Name) ($($currentSubscription.Id))" | timestamp

try {
    # Verify the target resource group exists
    $targetResourceGroup = Get-AzResourceGroup -Name $RESOURCEGROUP_NAME -ErrorAction Stop
    Write-Output "Target resource group '$RESOURCEGROUP_NAME' found." | timestamp
    
    # Verify the VM exists before attempting to start it
    $vm = Get-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $VM_NAME -ErrorAction Stop
    Write-Output "Target VM '$VM_NAME' found in resource group '$RESOURCEGROUP_NAME'." | timestamp
    
    # Check current VM status
    $vmStatus = Get-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $VM_NAME -Status
    $powerState = ($vmStatus.Statuses | Where-Object {$_.Code -like "PowerState/*"}).DisplayStatus
    Write-Output "Current VM status: $powerState" | timestamp
    
    # Start the virtual machine if it's not already running
    if ($powerState -eq "VM running") {
        Write-Output "VM '$VM_NAME' is already running. No action needed." | timestamp
    }
    else {
        Write-Output "Starting VM '$VM_NAME' in resource group '$RESOURCEGROUP_NAME'..." | timestamp
        $startResult = Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $VM_NAME
        
        if ($startResult.IsSuccessStatusCode) {
            Write-Output "VM '$VM_NAME' started successfully." | timestamp
        }
        else {
            Write-Warning "VM start operation completed but status code indicates potential issues." | timestamp
        }
    }
}
catch {
    # Handle errors during VM operations
    Write-Error -Message "Error during VM operation: $($_.Exception.Message)" | timestamp
    throw $_.Exception
}

# Log script completion
Write-Output "Script finished successfully." | timestamp