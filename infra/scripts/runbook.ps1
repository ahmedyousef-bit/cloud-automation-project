<#
.SYNOPSIS
    Runbook script to backup a blob file in Azure Storage Account.
.DESCRIPTION
    This script copies a specific blob file to a new blob name as a backup inside the same container.
#>

Write-Output "⏳ Starting backup operation..."

# Ensure Az modules are imported
Import-Module Az.Accounts -ErrorAction SilentlyContinue
Import-Module Az.Storage -ErrorAction SilentlyContinue

# Parameters (can be modified)
$resourceGroup = "my-rg"
$storageAccount = "mystorageacct"
$container = "data"
$sourceBlob = "important-data.json"
$backupBlob = "important-data-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

# Authenticate and get storage context
try {
    $storageAccountObj = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -ErrorAction Stop
    $ctx = $storageAccountObj.Context
    if (-not $ctx) {
        Write-Error "❌ Storage Context is null. Please check your credentials and account info."
        return
    }
} catch {
    Write-Error "❌ Failed to get Storage Context. Error: $($_.Exception.Message)"
    return
}

# Start backup operation
try {
    $copyStatus = Start-AzStorageBlobCopy `
        -SrcBlob $sourceBlob `
        -SrcContainer $container `
        -DestBlob $backupBlob `
        -DestContainer $container `
        -Context $ctx

    Write-Output "✅ Backup operation started. New blob: $backupBlob"
    Write-Output "Copy status: $($copyStatus.Status)"
} catch {
    Write-Error "❌ Failed to copy blob. Error: $($_.Exception.Message)"
}
