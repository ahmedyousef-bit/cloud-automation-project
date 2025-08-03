<#
.SYNOPSIS
    Runbook script to backup a blob file in Azure Storage Account.
.DESCRIPTION
    This script copies a specific blob file to a new blob name as a backup inside the same container.
#>

Write-Output "⏳ Starting backup operation..."

# Parameters (dynamic)
$resourceGroup = "my-rg"
$storageAccount = "mystorageacct"
$container = "data"
$sourceBlob = "important-data.json"
$backupBlob = "important-data-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

# Ensure Az module is imported
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Error "❌ Az module is not installed. Please install it using 'Install-Module Az' and try again."
    exit
}

# Authenticate and get storage context
try {
    $ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context
} catch {
    Write-Error "❌ Failed to get Storage Context. Error: $_"
    exit
}

# Check if source blob exists
$srcBlobObj = Get-AzStorageBlob -Container $container -Blob $sourceBlob -Context $ctx
if (-not $srcBlobObj) {
    Write-Error "❌ Source blob '$sourceBlob' does not exist in container '$container'."
    exit
}

# Start backup operation
try {
    Start-AzStorageBlobCopy `
        -SrcBlob $sourceBlob `
        -SrcContainer $container `
        -DestBlob $backupBlob `
        -DestContainer $container `
        -Context $ctx

    Write-Output "✅ Backup operation completed. New blob: $backupBlob"
} catch {
    Write-Error "❌ Failed to copy blob. Error: $_"
}
