# VMware VM Migration Script
param(
    [parameter(Mandatory=$true)]
    [string] $vCenterServer,

    [parameter(Mandatory=$true)]
    [string] $ClusterName,

    [parameter(Mandatory=$true)]
    [string] $SourceHostName,

    [parameter(Mandatory=$false)]
    [int] $MaxConcurrentMigrations = 5,

    [parameter(Mandatory=$true)]
    [string] $Username,

    [parameter(Mandatory=$true)]
    [string] $Password
)

filter timestamp {"[$(Get-Date -Format G)]: $_"}

Write-Output "Script started." | timestamp

try
{
    Write-Output "Connecting to vCenter $vCenterServer..." | timestamp
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)
    Connect-VIServer -Server $vCenterServer -Credential $credential
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$VerbosePreference = 'continue'

# Get cluster
$cluster = Get-Cluster -Name $ClusterName
if (-not $cluster) {
    Write-Error "Cluster $ClusterName not found."
    exit
}

# Get source host
$sourceHost = Get-VMHost -Name $SourceHostName
if (-not $sourceHost) {
    Write-Error "Host $SourceHostName not found."
    exit
}

if ($sourceHost.Parent -ne $cluster) {
    Write-Error "Host $SourceHostName is not in cluster $ClusterName."
    exit
}

# Get VMs on source host
$vms = Get-VM -Location $sourceHost
if (-not $vms) {
    Write-Output "No VMs found on host $SourceHostName." | timestamp
    exit
}

Write-Output "Found $($vms.Count) VMs to migrate from host $SourceHostName." | timestamp

# Get hosts in cluster, sorted by CPU and memory usage (lowest first)
$hosts = Get-VMHost -Location $cluster | Where-Object { $_.ConnectionState -eq "Connected" } | Sort-Object { $_.CpuUsageMhz / $_.CpuTotalMhz }, { $_.MemoryUsageGB / $_.MemoryTotalGB }
if (-not $hosts) {
    Write-Error "No connected hosts found in cluster $ClusterName."
    exit
}

$targetHost = $hosts[0]
Write-Output "Selected target host: $($targetHost.Name)" | timestamp

# Migrate VMs in batches
$batchSize = $MaxConcurrentMigrations
for ($i = 0; $i -lt $vms.Count; $i += $batchSize) {
    $batch = $vms[$i..([math]::Min($i + $batchSize - 1, $vms.Count - 1))]
    Write-Output "Starting batch migration of $($batch.Count) VMs..." | timestamp

    $jobs = @()
    foreach ($vm in $batch) {
        if ($vm.PowerState -ne "PoweredOn") {
            Write-Output "Skipping VM $($vm.Name): Not powered on." | timestamp
            continue
        }
        Write-Output "Starting migration of VM $($vm.Name) to $($targetHost.Name)..." | timestamp

        $job = Start-Job -ScriptBlock {
            param($vmName, $targetHostName, $vCenterServer, $credential)
            try {
                Connect-VIServer -Server $vCenterServer -Credential $credential -ErrorAction Stop
                $vm = Get-VM -Name $vmName
                $target = Get-VMHost -Name $targetHostName
                Move-VM -VM $vm -Destination $target -Confirm:$false
                "Migration of $vmName completed successfully."
            } catch {
                "Failed to migrate $vmName: $($_.Exception.Message)"
            } finally {
                Disconnect-VIServer -Server $vCenterServer -Confirm:$false
            }
        } -ArgumentList $vm.Name, $targetHost.Name, $vCenterServer, $credential
        $jobs += $job
    }

    # Wait for batch to complete
    $jobs | Wait-Job | Receive-Job | ForEach-Object { Write-Output $_ | timestamp }
    $jobs | Remove-Job
}

Disconnect-VIServer -Server $vCenterServer -Confirm:$false

Write-Output "Script finished." | timestamp