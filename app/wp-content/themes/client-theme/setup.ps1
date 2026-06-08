# Prompt for client name in Title Case
$name = Read-Host "Enter the Client Name (in Title Case, e.g., 'Dunder Mifflin')"
if ( [string]::IsNullOrEmpty($name)) {
	Write-Host "You must enter a name" -ForegroundColor Red
	Exit(1)
}
$kebabCaseName = $name.ToLower() -replace '\s+', '-'
$PascalCaseName = $name -replace '\s+', ''

Get-ChildItem -Recurse -Include "*.php", "*.scss", "*.json" | ForEach-Object {
	(Get-Content $_.FullName) -replace "Client Name", $name | Set-Content $_.FullName
	(Get-Content $_.FullName) -replace "client-name", $kebabCaseName | Set-Content $_.FullName
	(Get-Content $_.FullName) -replace "ClientName", $PascalCaseName | Set-Content $_.FullName
	Write-Host "Updated file: $( $_.FullName )" -ForegroundColor Green
}

# Install dependencies
pnpm install
composer install
composer dump-autoload -o

# Rename the directory
cd ..
$oldDir = "client-theme"
$newDir = $kebabCaseName

if (Test-Path $oldDir) {
	try {
		Rename-Item -Path $oldDir -NewName $newDir
		Write-Host "Renamed directory from $oldDir to $newDir" -ForegroundColor Green
	}
	catch {
		Write-Host "Error renaming directory: $_" -ForegroundColor Red
	}
}

# Delete the now-redundant files
cd $newDir
Remove-Item "README.md"
Remove-Item "setup.ps1"
