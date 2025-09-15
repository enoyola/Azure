<#
.SYNOPSIS
    Azure PowerShell script to copy a disk snapshot to a storage account
    
.DESCRIPTION
    This script copies an Azure disk snapshot to a storage account as a VHD file.
    Designed for execution in Azure Cloud Shell or local Azure CLI with PowerShell.
    Perfect for ad-hoc operations, disaster recovery, or one-time disk migrations.
    
.NOTES
    Author: Edward Noyola
    Version: 1.0
    Prerequisites: 
    - Azure PowerShell modules installed (or use Azure Cloud Shell)
    - Authenticated to Azure (az login or Cloud Shell)
    - Appropriate permissions on source snapshot and destination storage account
    
.EXAMPLE
    # Modify the variables below and run the script
    # Works great in Azure Cloud Shell - just paste and execute!
#>

# =============================================================================
# CONFIGURATION - Modify these variables for your specific use case
# =============================================================================

# SOURCE SNAPSHOT CONFIGURATION
$SnapshotResourceGroup = "MyResourceGroup"        # Resource group containing the snapshot
$SnapshotName = "vm_OSDisk-Snapshot"      # Name of the disk snapshot to copy

# DESTINATION STORAGE CONFIGURATION  
$StorageAccount = "mystorageaccount"               # Destination storage account name
$StorageAccountResourceGroup = "MyStorageRG"      # Resource group containing storage account
$StorageAccountBlob = "disks"                      # Container name (will be created if doesn't exist)
$VhdName = "vm_OSDisk-VHD"                # Destination VHD filename (without .vhd extension)

# OPERATION SETTINGS
$AccessDurationSeconds = 3600                      # SAS token duration (1 hour = 3600 seconds)

# =============================================================================
# SCRIPT EXECUTION - No changes needed below this line
# =============================================================================

# Custom filter to add timestamps to output messages
filter timestamp {"[$(Get-Date -Format G)]: $_"}

Write-Output "=== Azure Disk Copy Operation Started ===" | timestamp

try {
    # Verify Azure context (should be available in Cloud Shell or after az login)
    $context = Get-AzContext
    if (-not $context) {
        Write-Error "No Azure context found. Run 'Connect-AzAccount' first or use Azure Cloud Shell."
        exit 1
    }
    
    Write-Output "Using Azure context: $($context.Account.Id)" | timestamp
    Write-Output "Subscription: $($context.Subscription.Name)" | timestamp

    # Validate source snapshot exists
    Write-Output "Checking source snapshot..." | timestamp
    $snapshot = Get-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName -ErrorAction Stop
    Write-Output "✓ Snapshot found: $SnapshotName (Size: $($snapshot.DiskSizeGB) GB)" | timestamp

    # Validate destination storage account exists  
    Write-Output "Checking destination storage account..." | timestamp
    $storageAccountObj = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroup -Name $StorageAccount -ErrorAction Stop
    Write-Output "✓ Storage account found: $StorageAccount (Location: $($storageAccountObj.Location))" | timestamp

    # Get storage account key for authentication
    Write-Output "Retrieving storage account key..." | timestamp
    $StorageAccountKey = (Get-AzStorageAccountKey -Name $StorageAccount -ResourceGroupName $StorageAccountResourceGroup -ErrorAction Stop).Value[0]

    # Create storage context
    $DestStorageContext = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey -ErrorAction Stop
    Write-Output "✓ Storage context created" | timestamp

    # Check if container exists, create if needed
    try {
        $container = Get-AzStorageContainer -Context $DestStorageContext -Name $StorageAccountBlob -ErrorAction Stop
        Write-Output "✓ Container '$StorageAccountBlob' exists" | timestamp
    }
    catch {
        Write-Output "Creating container '$StorageAccountBlob'..." | timestamp
        $container = New-AzStorageContainer -Context $DestStorageContext -Name $StorageAccountBlob -Permission Off
        Write-Output "✓ Container created" | timestamp
    }

    # Grant temporary access to snapshot (creates SAS URI)
    Write-Output "Granting snapshot access..." | timestamp
    $snapshotAccess = Grant-AzSnapshotAccess -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName -DurationInSecond $AccessDurationSeconds -Access Read -ErrorAction Stop 
    Write-Output "✓ Snapshot access granted (Valid for $($AccessDurationSeconds/3600) hour(s))" | timestamp

    # Check if destination VHD already exists
    $destinationVhd = "$VhdName.vhd"
    try {
        $existingBlob = Get-AzStorageBlob -Context $DestStorageContext -Container $StorageAccountBlob -Blob $destinationVhd -ErrorAction Stop
        Write-Output "⚠️  WARNING: '$destinationVhd' already exists and will be overwritten!" | timestamp
    }
    catch {
        Write-Output "✓ Destination VHD '$destinationVhd' is available" | timestamp
    }

    # Start the copy operation
    Write-Output "=== STARTING COPY OPERATION ===" | timestamp
    Write-Output "From: Snapshot '$SnapshotName'" | timestamp  
    Write-Output "To: $StorageAccount/$StorageAccountBlob/$destinationVhd" | timestamp

    $copyOperation = Start-AzStorageBlobCopy -AbsoluteUri $snapshotAccess.AccessSAS -DestContainer $StorageAccountBlob -DestContext $DestStorageContext -DestBlob $destinationVhd -Force -ErrorAction Stop

    Write-Output "✓ Copy operation started successfully!" | timestamp
    Write-Output "Copy ID: $($copyOperation.CopyId)" | timestamp

    # Check initial copy status
    Write-Output "=== COPY STATUS ===" | timestamp
    $copyState = $copyOperation | Get-AzStorageBlobCopyState
    Write-Output "Status: $($copyState.Status)" | timestamp
    
    if ($copyState.Status -eq "Success") {
        Write-Output "🎉 Copy completed immediately!" | timestamp
    }
    elseif ($copyState.Status -eq "Pending") {
        Write-Output "📋 Copy is running in the background..." | timestamp
        Write-Output "   Monitor progress in Azure Storage Explorer or Portal" | timestamp
        Write-Output "   The copy will complete automatically" | timestamp
        
        # Show progress if available
        if ($copyState.TotalBytes -gt 0) {
            $percentComplete = [math]::Round(($copyState.BytesCopied / $copyState.TotalBytes) * 100, 1)
            Write-Output "   Progress: $($copyState.BytesCopied) / $($copyState.TotalBytes) bytes ($percentComplete%)" | timestamp
        }
    }
    else {
        Write-Output "⚠️  Copy status: $($copyState.Status)" | timestamp
        if ($copyState.StatusDescription) {
            Write-Output "   Details: $($copyState.StatusDescription)" | timestamp
        }
    }

    # Provide useful information for monitoring
    Write-Output "=== OPERATION COMPLETE ===" | timestamp
    Write-Output "✓ Snapshot access will expire automatically in $($AccessDurationSeconds/3600) hour(s)" | timestamp
    Write-Output "✓ Final VHD location: https://$StorageAccount.blob.core.windows.net/$StorageAccountBlob/$destinationVhd" | timestamp
    Write-Output "✓ Use 'Get-AzStorageBlobCopyState' to check copy progress if needed" | timestamp
}
catch {
    Write-Error "❌ Error during copy operation: $($_.Exception.Message)" | timestamp
    Write-Output "=== OPERATION FAILED ===" | timestamp
    exit 1
}

Write-Output "=== Script completed ===" | timestamp