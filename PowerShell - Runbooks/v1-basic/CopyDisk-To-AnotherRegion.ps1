# SOURCE
$SnapshotResourceGroup = "Resource Group Source"
$SnapshotName = "Snapshot Disk name"

# DESTINATION
$StorageAccount = "Storage Account destination name"
$StorageAccountBlob = "Blob name"
$storageaccountResourceGroup = "Resource Group Destination"
$vhdname = "VHD name that will have in the storage"


#SA_KEY
$StorageAccountKey = (Get-AzStorageAccountKey -Name $StorageAccount -ResourceGroupName $storageaccountResourceGroup).value[0]
$snapshot = Get-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName

#GRANTING ACCESS
$snapshotaccess = Grant-AzSnapshotAccess -ResourceGroupName $SnapshotResourceGroup -SnapshotName $SnapshotName -DurationInSecond 10000 -Access Read -ErrorAction stop 
   
$DestStorageContext = New-AzStorageContext –StorageAccountName $storageaccount -StorageAccountKey $StorageAccountKey -ErrorAction stop

Write-Output "START COPY"
$copyOperation = Start-AzStorageBlobCopy -AbsoluteUri $snapshotaccess.AccessSAS -DestContainer $StorageAccountBlob -DestContext $DestStorageContext -DestBlob "$($vhdname).vhd" -Force -ErrorAction stop
Write-Output "END COPY"

$copyOperation | Get-AzStorageBlobCopyState