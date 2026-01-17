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
$confirmation = Read-Host "Install/update Composer dependencies? (y/n)"
if ($confirmation -ne 'y') {
	Write-Host "✘ Skipping Composer install/update." -ForegroundColor Yellow
}
else {
	if (Test-Path "composer.json") {
		Write-Host "Installing dependencies via Composer..." -ForegroundColor Cyan
		composer update
	}
	else {
		Write-Host "✘ composer.json not found. Skipping composer install." -ForegroundColor Yellow
	}
}

# Put some space between next steps in the terminal
Write-Host "-------------------------------`n"

# Copy ACF Pro from user directory to wp-content/plugins
$acfSource = Join-Path $env:USERPROFILE "/PhpStormProjects/advanced-custom-fields-pro"
$acfDestination = Join-Path (Get-Location) "app/wp-content/plugins/advanced-custom-fields-pro"
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
	# Install WordPress
	wp core install --url="http://$folderName.test" --title="$folderName" --admin_user="doubleedesign" --admin_password="doubleedesign" --admin_email="leesa@doubleedesign.com.au"
} else {
	Write-Host "✔ WordPress is already installed." -ForegroundColor Green
}

# Activate Comet Canvas theme
wp theme activate comet-canvas-blocks

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
