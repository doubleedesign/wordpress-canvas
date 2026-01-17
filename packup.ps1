# Check that commands are available
$commands = @("mysql", "mysqldump")
foreach ($command in $commands) {
	if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
		Write-Host "✘ $command is not available." -ForegroundColor Red
		exit 1
	}
	Write-Host "✔ $command is available" -ForegroundColor Green
}

# Export the WordPress database to the sql directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$folderName = Split-Path -Leaf (Get-Location)
$transformedFolderName = $folderName -replace '-', '_' # Remove hyphens from folder name for database compatibility
$databaseName = "${transformedFolderName}_dev"
$sqlDirectory = Join-Path (Get-Location) "sql"
if (-not (Test-Path $sqlDirectory)) {
	New-Item -ItemType Directory -Path $sqlDirectory | Out-Null
}
$sqlFilePath = Join-Path $sqlDirectory "${databaseName}-${timestamp}.sql"
$exportCommand = "mysqldump --user=root --host=localhost --port=3309 $databaseName > `"$sqlFilePath`""
Invoke-Expression $exportCommand

if (Test-Path $sqlFilePath) {
	Write-Host "✔ Database exported to $sqlFilePath" -ForegroundColor Green
} else {
	Write-Host "✘ Failed to export database." -ForegroundColor Red
}

# Commit it to Git
git add $sqlFilePath
git commit -m "Database export: ${databaseName} at ${timestamp}"
Write-Host "✔ Database export committed to Git." -ForegroundColor Green

