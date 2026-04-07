if (Test-Path "wordpress") {
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

	if ($errors.Count -gt 0) {
		Write-Host "Error moving WordPress core after composer install or update." -ForegroundColor Red
		exit 1
	}
	else {
		Write-Host "WordPress core moved successfully after composer install or update." -ForegroundColor Green
	}
}


$scriptLocation = $PSScriptRoot
$ENV:COMPOSER = "composer.json"

$themes = Get-ChildItem -Path "app\wp-content\themes" -Directory
$pluginsToComposerUpdate = @(
	"app\wp-content\plugins\doublee-base-plugin",
	"app\wp-content\plugins\doublee-breadcrumbs",
	"app\wp-content\plugins\doublee-ninja-markup",
	"app\wp-content\plugins\doublee-tinymce",
	"app\wp-content\plugins\comet-plugin-blocks"
)

$packagesToUpdate = ($themes | Select-Object -ExpandProperty FullName) + $packagesToComposerUpdate

$devMode = $Env:POWERPRESS_DEV
if ($devMode -eq "1") {
	foreach ($package in $packagesToUpdate) {
		if (Test-Path $package) {
			# If this is a symlinked directory, use its real directory - this helps with path issues when it has its own symlinked dependencies
			$item = Get-Item $package
			if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
				$package = $item.Target
				Write-Host "Resolved symlink to $( $package )" -ForegroundColor Cyan
			}

			# When processing the Comet Blocks plugin, also ensure the local core package is up-to-date
			if ($package -eq "app\wp-content\plugins\comet-plugin-blocks") {
				$corePath = Join-Path (Split-Path $package -Parent) "core"
				if (Test-Path $corePath) {
					Set-Location $corePath
					try {
						Write-Host "Running composer update for Comet Components Core" -ForegroundColor Cyan
						composer update --prefer-source --no-dev
						composer dump-autoload -o
					}
					catch {
						Write-Host "Error running composer update for Comet Components Core" -ForegroundColor Red
						Write-Host "You might need to run it from its source directory manually to work around symlink issues" -ForegroundColor Yellow
					}
				}
			}

			# Ensure we are in the plugin directory before proceeding
			Set-Location $package

			if (Test-Path (Join-Path $package "composer.local.json")) {
				try {
					$ENV:COMPOSER = "composer.local.json"
					Write-Host "Running composer update with local package config for $package" -ForegroundColor Cyan
					composer update --prefer-source --no-dev
					composer dump-autoload -o

					if (Test-Path "package.json") {
						Write-Host "Running npm install for $package" -ForegroundColor Cyan
						npm install
					}
				}
				catch {
					Write-Host "Error running composer update for $package" -ForegroundColor Red
					Write-Host "You might need to run it from its source directory manually to work around symlink issues" -ForegroundColor Yellow
				}
				finally {
					$ENV:COMPOSER = "composer.json"
					Set-Location $scriptLocation
				}
			}
			else {
				try {
					if (Test-Path "composer.json") {
						Write-Host "Running composer update for $package" -ForegroundColor Cyan
						composer update --prefer-source --no-dev
						composer dump-autoload -o
					}

					if (Test-Path "package.json") {
						Write-Host "Running npm install for $package" -ForegroundColor Cyan
						npm install
					}
				}
				catch {
					Write-Host "Error running composer update for $package" -ForegroundColor Red
					Write-Host "You might need to run it from its source directory manually to work around symlink issues" -ForegroundColor Yellow
				}
				finally {
					Set-Location $scriptLocation
				}
			}
		}
		else {
			Write-Host "$package not found, skipping composer update" -ForegroundColor Yellow
		}
	}
}

Set-Location $scriptLocation
