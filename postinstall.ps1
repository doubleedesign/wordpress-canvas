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

$pluginsToComposerUpdate = @(
	"app\wp-content\plugins\doublee-base-plugin",
	"app\wp-content\plugins\doublee-breadcrumbs",
	"app\wp-content\plugins\doublee-ninja-markup",
	"app\wp-content\plugins\doublee-tinymce",
	"app\wp-content\plugins\comet-plugin-blocks"
)

$devMode = $Env:POWERPRESS_DEV

foreach ($plugin in $pluginsToComposerUpdate) {
	Set-Location $scriptLocation
	if (Test-Path $plugin) {
		if (($devMode -eq "1") -and (Test-Path (Join-Path $plugin "composer.local.json"))) {
			try {
				$ENV:COMPOSER = "composer.local.json"
				Write-Host "Running composer update in dev mode for $plugin" -ForegroundColor Cyan
				Set-Location $plugin
				composer update --prefer-source
				composer dump-autoload -o
			}
			catch {
				Write-Host "Error running composer update in dev mode for $plugin" -ForegroundColor Red
				Write-Host "You might need to run it from its source directory manually to work around symlink issues" -ForegroundColor Yellow
			}
			finally {
				$ENV:COMPOSER = "composer.json"
			}
		}
		else {
			Write-Host "Running composer update for $plugin" -ForegroundColor Cyan
			Set-Location $plugin
			composer update --no-dev --prefer-dist
			composer dump-autoload -o
		}
	}
	else {
		Write-Host "$plugin not found, skipping composer update" -ForegroundColor Yellow
	}
}

Set-Location $scriptLocation
