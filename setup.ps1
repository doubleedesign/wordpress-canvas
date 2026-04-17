$useDevMode = Read-Host "Do you want to use dev mode (local symlinked packages, etc)? (y/N)"
if ($useDevMode -eq "y" -or $useDevMode -eq "Y") {
	Write-Host "Using dev mode" -ForegroundColor Cyan
	$env:POWERPRESS_DEV = 1
	$env:COMPOSER = "composer.dev.json"
	composer update
	& .\postinstall.ps1
    & .\update-phpstorm-meta.ps1

	Write-Host "Dependency installation/updates complete." -ForegroundColor Green
}
else {
	Write-Host "Using production mode" -ForegroundColor Cyan
	$env:POWERPRESS_DEV = 0
	$env:COMPOSER = "composer.json"
	composer update --no-dev
    & .\update-phpstorm-meta.ps1

	Write-Host "Dependency installation/updates complete." -ForegroundColor Green
	Write-Host "You may need to run composer update and npm install in your project-specific theme and plugin directories." -ForegroundColor Cyan
}

Write-Host "Sorry, this script doesn't automatically handle the database import yet." -ForegroundColor Yellow
