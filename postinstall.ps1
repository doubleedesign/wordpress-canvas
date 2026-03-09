Write-Host "Moving WordPress core into app directory..." -ForegroundColor Cyan
$source = "wordpress"
$destination = "app"

Get-ChildItem -Path $source | ForEach-Object {
	$destPath = Join-Path $destination $_.Name
	if (Test-Path $destPath) {
		Remove-Item -Path $destPath -Recurse -Force
	}
	Move-Item -Path $_.FullName -Destination $destination -Force
}

Remove-Item -Path $source -Recurse -Force

# Check a representative sample of files and directories
$testFiles = @(
	"app\index.php",
	"app\wp-admin",
	"app\wp-admin\admin.php",
	"app\wp-includes",
	"app\wp-includes\template.php"
)
$errors = @()
foreach ($testFile in $testFiles) {
	if (Test-Path $testFile) {
		Write-Host "Verified: $testFile" -ForegroundColor Green
	}
	else {
		Write-Host "$testFile not found" -ForegroundColor Red
		$errors += $testFile
	}
}

if($errors.Count -gt 0) {
	Write-Host "Error moving WordPress core after composer install or update." -ForegroundColor Red
	exit 1
}
else {
	Write-Host "WordPress core moved successfully after composer install or update." -ForegroundColor Green
}
