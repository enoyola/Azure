<#
.SYNOPSIS
Starts an Azure VM safely (idempotent) from an Azure Automation runbook.

.DESCRIPTION
- Authenticates with Managed Identity (system-assigned by default; user-assigned supported).
- Verifies the target VM exists.
- Checks current power state to avoid redundant starts.
- Optionally waits until the VM reaches "running".
- Emits structured output (object) you can consume in jobs or alerts.

.PARAMETER ResourceGroupName
Resource group containing the VM.

.PARAMETER VmName
Name of the Virtual Machine to start.

.PARAMETER IdentityClientId
(OPTIONAL) Client ID of a *user-assigned* managed identity to use for login.
If omitted, the runbook uses the system-assigned managed identity.

.PARAMETER Wait
If provided, the runbook polls the VM until it is "running" (or timeout).

.PARAMETER TimeoutMinutes
Maximum minutes to wait for the VM to become running when -Wait is used. Default: 10.

.EXAMPLE
.\Start-AzVm-Runbook.ps1 -ResourceGroupName rg-app -VmName vm-app-01 -Verbose

.EXAMPLE
.\Start-AzVm-Runbook.ps1 -ResourceGroupName rg-app -VmName vm-app-01 -Wait -TimeoutMinutes 15

.NOTES
Author: Edward Noyola
Run As: Managed Identity (Azure Automation)
Requires: Az.Accounts, Az.Compute, Az.Resources
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $VmName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $IdentityClientId,

    [switch] $Wait,

    [int] $TimeoutMinutes = 10
)

# Make non-terminating errors terminate so try/catch can handle them
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Simple timestamp helper for consistent logs
filter Add-Timestamp { "[$(Get-Date -Format u)] $_" }

function Invoke-WithRetry {
    <#
    .SYNOPSIS
    Retries a scriptblock with basic exponential backoff (for transient 429/5xx).
    #>
    param(
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,

        [int] $MaxAttempts = 4,
        [int] $BaseDelaySeconds = 2
    )
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            return & $ScriptBlock
        } catch {
            if ($i -eq $MaxAttempts) { throw }
            $delay = [math]::Pow(2, $i - 1) * $BaseDelaySeconds
            Write-Warning ("Attempt {0} failed: {1}. Retrying in {2}s..." -f $i, $_.Exception.Message, $delay)
            Start-Sleep -Seconds $delay
        }
    }
}

function Get-VmPowerState {
    <#
    .SYNOPSIS
    Returns the VM power state string (e.g., 'VM running', 'VM deallocated').
    #>
    param(
        [string] $ResourceGroupName,
        [string] $VmName
    )
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status -ErrorAction Stop
    # The Status call returns a Statuses list; the entry with Code like 'PowerState/running'
    $state = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -First 1)
    return $state.DisplayStatus
}

Write-Output "Script started." | Add-Timestamp

try {
    # --- Authentication (Managed Identity) ---
    Write-Verbose "Connecting to Azure using Managed Identity..."
    if ($PSBoundParameters.ContainsKey('IdentityClientId')) {
        # Use a user-assigned managed identity if a client ID was provided
        Connect-AzAccount -Identity -AccountId $IdentityClientId | Out-Null
    } else {
        # Default to system-assigned managed identity
        Connect-AzAccount -Identity | Out-Null
    }

    # (Optional) If you need to force a specific subscription, set it here:
    # Set-AzContext -Subscription '00000000-0000-0000-0000-000000000000' | Out-Null

    # --- Validate the resource group and VM exist ---
    Write-Verbose "Validating resource group '$ResourceGroupName'..."
    Invoke-WithRetry { Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop } | Out-Null

    Write-Verbose "Retrieving VM '$VmName'..."
    $vmObj = Invoke-WithRetry { Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction Stop }

    # --- Check current power state for idempotency ---
    $currentState = Get-VmPowerState -ResourceGroupName $ResourceGroupName -VmName $VmName
    Write-Verbose "Current power state: $currentState"

    $alreadyRunning = $currentState -eq 'VM running'

    if ($alreadyRunning) {
        Write-Output "VM '$VmName' is already running. No action taken." | Add-Timestamp
    }
    elseif ($PSCmdlet.ShouldProcess("vm/$VmName","Start-AzVM")) {
        Write-Verbose "Starting VM '$VmName' in resource group '$ResourceGroupName'..."
        # Use retry wrapper for transient issues
        Invoke-WithRetry { Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction Stop | Out-Null }
        Write-Output "Start command issued to VM '$VmName'." | Add-Timestamp
    }

    # --- Optionally wait for 'VM running' ---
    if ($Wait -and -not $alreadyRunning) {
        $deadline = (Get-Date).ToUniversalTime().AddMinutes($TimeoutMinutes)
        do {
            Start-Sleep -Seconds 10
            $state = Get-VmPowerState -ResourceGroupName $ResourceGroupName -VmName $VmName
            Write-Verbose "Waiting... current state: $state"
            if ($state -eq 'VM running') { break }
        } while ((Get-Date).ToUniversalTime() -lt $deadline)

        if ($state -ne 'VM running') {
            throw "VM '$VmName' did not reach 'VM running' within $TimeoutMinutes minute(s). Last state: $state"
        }
        Write-Output "VM '$VmName' is now running." | Add-Timestamp
    }

    # --- Emit structured output for downstream steps ---
    $finalState = Get-VmPowerState -ResourceGroupName $ResourceGroupName -VmName $VmName
    [pscustomobject]@{
        VmName        = $VmName
        ResourceGroup = $ResourceGroupName
        FinalState    = $finalState
        TimestampUtc  = (Get-Date).ToUniversalTime()
    }
}
catch {
    Write-Error ("Runbook failed: {0}" -f $_.Exception.Message)
    throw
}
finally {
    Write-Output "Script finished." | Add-Timestamp
}
