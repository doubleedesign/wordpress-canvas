# Backup wp-config.php and wp-content before Composer install
function backupPersistentWpFiles {
	$backupPath = Join-Path (Get-Location) ".wp-backup"
	$appPath = Join-Path (Get-Location) "app"

	# Create backup directory if it doesn't exist
	if (-not (Test-Path $backupPath)) {
		New-Item -ItemType Directory -Path $backupPath | Out-Null
	}

	# Backup wp-config.php
	$wpConfigPath = Join-Path $appPath "wp-config.php"
	if (Test-Path $wpConfigPath) {
		Copy-Item -Path $wpConfigPath -Destination $backupPath -Force
		Write-Host "✔ Backed up wp-config.php" -ForegroundColor Green
	}

	# Create wp-content directory in backup
	$backupWpContentPath = Join-Path $backupPath "wp-content"
	if (-not (Test-Path $backupWpContentPath)) {
		New-Item -ItemType Directory -Path $backupWpContentPath | Out-Null
	}

	# Backup wp-content/uploads if it exists
	$wpContentPath = Join-Path $appPath "wp-content/uploads"
	if (Test-Path $wpContentPath) {
		Copy-Item -Path $wpContentPath -Destination $backupWpContentPath -Recurse -Force
		Write-Host "✔ Backed up wp-content/uploads" -ForegroundColor Green
	}

	$depsToSkip = @("index.php")
	# Get plugins to skip from composer.json dependencies
	$composerJsonPath = Join-Path (Get-Location) "composer.json"
	if (Test-Path $composerJsonPath) {
		$composerJson = Get-Content $composerJsonPath | ConvertFrom-Json
		if ($composerJson.require) {
			foreach ($dependency in $composerJson.require.PSObject.Properties) {
				# Split at / and take just the last bit
				$pluginName = $dependency.Name.Split('/')[-1]
				$depsToSkip += $pluginName
			}
		}
	}

	# Back up plugins not in the list
	$wpPluginsPath = Join-Path $appPath "wp-content/plugins"
	if (Test-Path $wpPluginsPath) {
		$allPlugins = Get-ChildItem -Path $wpPluginsPath
		foreach ($plugin in $allPlugins) {
			if ($depsToSkip -notcontains $plugin.Name) {
				$destinationPath = Join-Path $backupPath "plugins/$( $plugin.Name )"
				Copy-Item -Path $plugin.FullName -Destination $destinationPath -Recurse -Force
				Write-Host "✔ Backed up plugin: $( $plugin.Name )" -ForegroundColor Green
			}
		}
	}

	# Back up themes other than comet-canvas-blocks
	$wpThemesPath = Join-Path $appPath "wp-content/themes"
	if (Test-Path $wpThemesPath) {
		$allThemes = Get-ChildItem -Path $wpThemesPath
		# Exlcude non-directory items
		$allThemes = $allThemes | Where-Object { $_.PSIsContainer }
		foreach ($theme in $allThemes) {
			if ($theme.Name -ne "comet-canvas-blocks") {
				$destinationPath = Join-Path $backupPath "themes/$( $theme.Name )"
				Copy-Item -Path $theme.FullName -Destination $destinationPath -Recurse -Force
				Write-Host "✔ Backed up theme: $( $theme.Name )" -ForegroundColor Green
			}
		}
	}
}

# Restore wp-config.php and wp-content after Composer install
function restorePersistentWpFiles {
	$backupPath = Join-Path (Get-Location) ".wp-backup"
	$appPath = Join-Path (Get-Location) "app"

	if (-not (Test-Path $backupPath)) {
		return
	}

	# Restore wp-config.php
	$wpConfigBackup = Join-Path $backupPath "wp-config.php"
	if (Test-Path $wpConfigBackup) {
		Copy-Item -Path $wpConfigBackup -Destination $appPath -Force
		Write-Host "✔ Restored wp-config.php" -ForegroundColor Green
	}

	# Restore wp-content (merge with new installation)
	$wpContentBackup = Join-Path $backupPath "wp-content"
	if (Test-Path $wpContentBackup) {
		Copy-Item -Path "$wpContentBackup\*" -Destination (Join-Path $appPath "wp-content") -Recurse -Force
		Write-Host "✔ Restored wp-content" -ForegroundColor Green
	}

	# Clean up backup
	Remove-Item -Path $backupPath -Recurse -Force
}

# -------------- START SCRIPT -------------- #
# Check that commands are available
$commands = @("php", "composer", "mysql", "herd", "wp")
foreach ($command in $commands) {
	if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
		Write-Host "✘ $command is not available." -ForegroundColor Red
		exit 1
	}
	Write-Host "✔ $command is available" -ForegroundColor Green
}

# Install everything via Composer after user confirmation
$confirmation = Read-Host "Install Composer dependencies? (y/n)"
if ($confirmation -ne 'y') {
	Write-Host "✘ Skipping Composer install/update." -ForegroundColor Yellow
}
else {
	if (Test-Path "composer.json") {
		backupPersistentWpFiles

		Write-Host "Installing dependencies via Composer..." -ForegroundColor Cyan
		composer install

		restorePersistentWpFiles
	}
	else {
		Write-Host "✘ composer.json not found. Skipping composer install." -ForegroundColor Yellow
	}
}

# Put some space between next steps in the terminal
Write-Host "-------------------------------`n"

# Check that the WordPress files are present before proceeding
$appPath = Join-Path (Get-Location) "app"
$wpCoreFile = Join-Path $appPath "wp-load.php"
if (-not (Test-Path $wpCoreFile)) {
	Write-Host "✘ WordPress core files not found in 'app' directory. Please ensure WordPress is installed there to proceed." -ForegroundColor Red
	Write-Host "You may need to delete composer.lock and the vendor directory, then run 'composer install' again." -ForegroundColor Red
	exit 1n
}

# Copy ACF Pro from user directory to wp-content/plugins
$acfSource = Join-Path $env:USERPROFILE "/PhpStormProjects/advanced-custom-fields-pro"
$acfDestination = Join-Path (Get-Location) "app/wp-content/plugins"
if (Test-Path $acfSource) {
	Copy-Item -Path $acfSource -Destination $acfDestination -Recurse -Force
	Write-Host "✔ ACF Pro copied to plugins directory." -ForegroundColor Green
} else {
	Write-Host "✘ ACF Pro source not found at '$acfSource'. Skipping." -ForegroundColor Red
}

# Delete default themes if they exist - anything starting with twenty* in wp-content/themes
$themesPath = Join-Path (Get-Location) "app/wp-content/themes"
if (Test-Path $themesPath) {
	$defaultThemes = Get-ChildItem -Path $themesPath | Where-Object { $_.Name -like "twenty*" }
	foreach ($theme in $defaultThemes) {
		Remove-Item -Path $theme.FullName -Recurse -Force
		Write-Host "✔ Deleted default theme: $( $theme.Name )" -ForegroundColor Green
	}
}

# Delete Hello Dolly and Akismet plugins if they exist
$pluginsPath = Join-Path (Get-Location) "app/wp-content/plugins"
if (Test-Path $pluginsPath) {
	$defaultPlugins = @("hello.php", "akismet")
	foreach ($plugin in $defaultPlugins) {
		$pluginPath = Join-Path $pluginsPath $plugin
		if (Test-Path $pluginPath) {
			Remove-Item -Path $pluginPath -Recurse -Force
			Write-Host "✔ Deleted default plugin: $plugin" -ForegroundColor Green
		}
	}
}

Write-Host "-------------------------------`n"

# Get current folder name and set database name
$folderName = Split-Path -Leaf (Get-Location)
$transformedFolderName = $folderName -replace '-', '_' # Remove hyphens from folder name for database compatibility
$databaseName = "${transformedFolderName}_dev"

# Create database if it doesn't exist
$checkDbQuery = "SHOW DATABASES LIKE '$databaseName';"
$dbExists = & mysql -P 3309 -u root -e $checkDbQuery | Select-String $databaseName
if (-not $dbExists) {
	Write-Host "✘ Database '$databaseName' does not exist." -ForegroundColor Yellow
	$createDbQuery = "CREATE DATABASE $databaseName"
	& mysql -P 3309 -u root -e $createDbQuery
	Write-Host "✔ Database '$databaseName' created." -ForegroundColor Green
} else {
	Write-Host "✔ Database '$databaseName' already exists." -ForegroundColor Green
}

# Check if there is a matching database export in the sql folder and import it if so, overwriting the existing database
# Look in the sql folder for any file starting with the database name, as they have timestamps appended
$sqlDirectory = Join-Path (Get-Location) "sql"
$matchingSqlFiles = Get-ChildItem -Path $sqlDirectory | Where-Object { $_.Name -like "$databaseName*.sql" }
if ($matchingSqlFiles.Count -gt 0) {
	# Get the most recent file based on LastWriteTime
	$latestSqlFile = $matchingSqlFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

	# Prompt the user to confirm whether to import the database
	Write-Host "✔ Found matching database export: '$($latestSqlFile.Name)'." -ForegroundColor Green
	$confirmation = Read-Host "Do you want to import this database and overwrite the existing one? (y/n)"
	if ($confirmation -ne 'y') {
		Write-Host "✘ Database import cancelled by user. Skipping import." -ForegroundColor Yellow
	}
	else {
		try {
			$sqlFilePath = $latestSqlFile.FullName
			Write-Host "Importing database from '$sqlFilePath'..." -ForegroundColor Cyan
			Get-Content $sqlFilePath | mysql --user=root --host=localhost --port=3309 $databaseName
			Write-Host "✔ Database imported successfully." -ForegroundColor Green
		}
		catch {
			# Get the error message
			$errorMessage = $_.Exception.Message
			Write-Host "✘ Failed to import database. ${errorMessage}" -ForegroundColor Red
		}
	}
} else {
	Write-Host "✘ No matching database export found in 'sql' folder for '$databaseName'. Skipping import." -ForegroundColor Yellow
}

Write-Host "-------------------------------`n"

# Check if WordPress is installed using the given database name, and if not do so
cd app
$wpCheck = wp db check
if ($LASTEXITCODE -ne 0) {
	Write-Host "✘ WordPress is not installed. Installing now..." -ForegroundColor Yellow
	wp core install --url="http://$folderName.test" --title="$folderName" --admin_user="doubleedesign" --admin_password="doubleedesign" --admin_email="leesa@doubleedesign.com.au"
} else {
	Write-Host "✔ WordPress is already installed." -ForegroundColor Green
}

# Activate Comet Canvas theme
wp theme activate comet-canvas-blocks

# Confirm whether to install dev dependencies in custom plugin projects
$confirmation = Read-Host "This script is about to run Composer update in the local custom plugin directories. Do you want to include their dev dependencies? (y/n)"
$withDevDeps = $false
if ($confirmation -eq 'y') {
	$withDevDeps = $true
	Write-Host "✔ Installing with dev dependencies." -ForegroundColor Green
} else {
	Write-Host "✔ Installing without dev dependencies." -ForegroundColor Green
}

# Go into the custom plugin directories and run Composer install
$customPlugins = @("doublee-base-plugin", "doublee-breadcrumbs", "doublee-local-dev", "doublee-ninja-markup", "doublee-tinymce", "comet-plugin-blocks", "acf-advanced-image-field")
foreach ($plugin in $customPlugins) {
	$pluginPath = Join-Path (Get-Location) "wp-content/plugins/$plugin"
	if (Test-Path $pluginPath) {
		Write-Host "Running Composer install for plugin: $plugin" -ForegroundColor Cyan
		cd $pluginPath

		# Check if there is a composer.local.json file and use that
		if (Test-Path (Join-Path $pluginPath "composer.local.json")) {
			Write-Host "✔ Using composer.local.json for $plugin" -ForegroundColor Green
			if( $withDevDeps ) {
				$env:COMPOSER = "composer.local.json"; composer update --prefer-source
				composer dump-autoload -o
			} else {
				$env:COMPOSER = "composer.local.json"; composer update --prefer-source --no-dev
				composer dump-autoload -o
			}
			cd - | Out-Null
		}
		# Otherwise, reset the env variable to use the default composer.json
		else {
			$env:COMPOSER = $null;
			if( $withDevDeps ) {
				composer update --prefer-source
				composer dump-autoload -o
			} else {
				composer update --prefer-source --no-dev
				composer dump-autoload -o
			}
			cd - | Out-Null
		}
	} else {
		Write-Host "✘ Plugin directory not found: $plugin" -ForegroundColor Red
	}
}

# Activate the plugins in the appropriate order (accounting for dependencies some of them have)
wp plugin activate advanced-custom-fields-pro
wp plugin activate doublee-local-dev
wp plugin activate doublee-base-plugin
wp plugin activate doublee-breadcrumbs
wp plugin activate acf-advanced-image-field
wp plugin activate comet-plugin-blocks
wp plugin activate doublee-tinymce
wp plugin activate comet-calendar
wp plugin activate ninja-forms
wp plugin activate doublee-ninja-markup
wp plugin activate autodescription
wp plugin activate simply-disable-comments

# Set up with Herd
herd link $folderName
herd secure

# Navigate back to main project directory
cd ..

# Launch the site in the browser
Start-Process "https://$folderName.test/wp-admin"
