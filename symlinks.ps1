# Define the real directories/files and their corresponding symlink directories/files
# This assumes we're in a site in C:/USERNAME/LocalSites, and other repos are in C:/USERNAME/PHPStormProjects
$symlinks = @(
	@{ destination = ".\app\public\wp-content\plugins\doublee-breadcrumbs"; source = "..\..\PHPStormProjects\doublee-breadcrumbs" },
	@{ destination = ".\app\public\wp-content\plugins\doublee-base-plugin"; source = "..\..\PHPStormProjects\doublee-base-plugin" },
	@{ destination = ".\app\public\wp-content\plugins\comet-plugin"; source = "..\..\PHPStormProjects\comet-components\packages\comet-plugin" }
	@{ destination = ".\app\public\wp-content\plugins\comet-calendar"; source = "..\..\PHPStormProjects\comet-components\packages\comet-calendar" },
	@{ destination = ".\app\public\wp-content\plugins\block-supports-extended"; source = "..\..\PHPStormProjects\comet-components\vendor\humanmade\block-supports-extended" },
	@{ destination = ".\app\public\wp-content\plugins\gutenberg"; source = "..\..\PHPStormProjects\comet-components\vendor\wordpress\gutenberg" },
	@{ destination = ".\app\public\wp-content\themes\comet-canvas"; source = "..\..\PHPStormProjects\comet-components\packages\comet-canvas" },
	@{ destination = ".\app\public\wp-content\plugins\comet-table-block"; source = "..\..\PHPStormProjects\comet-table-block" }
)

# Function to create directories if they don't exist
function Ensure-DirectoryExists {
	param (
		[string]$directoryPath
	)
	if (-not (Test-Path $directoryPath)) {
		New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
		Write-Host "Created directory: $directoryPath"
	}
}

# Function to create symbolic links for both files and directories
function Create-Symlink {
	param (
		[string]$realPath,
		[string]$symlinkPath
	)

	# Ensure the real path exists
	Ensure-DirectoryExists -directoryPath $realPath
	$resolvedRealPath = Resolve-Path -Path $realPath

	# Ensure the parent directory of the symlink exists
	$symlinkDir = Split-Path -Parent $symlinkPath
	Ensure-DirectoryExists -directoryPath $symlinkDir

	# Create the symlink
	if (!(Test-Path $symlinkPath)) {
		Write-Host "Creating directory symlink: $symlinkPath -> $resolvedRealPath"
		New-Item -ItemType SymbolicLink -Path $symlinkPath -Target $resolvedRealPath | Out-Null
	} else {
		$item = Get-Item $symlinkPath -Force
		if ($item.LinkType -eq "SymbolicLink") {
			Write-Host "Symlink already exists: $symlinkPath"
		} else {
			Write-Host "Warning: Path exists but is not a symlink: $symlinkPath. Deleting folder and symlinking to $resolvedRealPath"
			Remove-Item -Path $symlinkPath -Recurse
			New-Item -ItemType SymbolicLink -Path $symlinkPath -Target $resolvedRealPath | Out-Null
		}
	}

	# Confirm symlink creation
	if (Test-Path $symlinkPath) {
		$item = Get-Item $symlinkPath -Force
		if ($item.LinkType -eq "SymbolicLink") {
			Write-Host "Verified symlink: $symlinkPath -> $($item.Target)"
		}
	}
}

# Function to safely delete a symlink
function Remove-Symlink {
	param (
		[string]$symlinkPath
	)

	if (Test-Path $symlinkPath) {
		$item = Get-Item $symlinkPath -Force
		if ($item.LinkType -eq "SymbolicLink") {
			Remove-Item -Path $symlinkPath -Recurse
			Write-Host "Deleted symlink: $symlinkPath"
		} else {
			Write-Host "Warning: Path exists but is not a symlink, skipping deletion: $symlinkPath"
		}
	} else {
		Write-Host "Path does not exist: $symlinkPath"
	}
}

# Iterate over each pair of real and symlink directories/files
foreach ($link in $symlinks) {
	# Safely remove existing symlink if it exists
	Remove-Symlink -symlinkPath $link.destination
	# Create/re-create the symlink
	Create-Symlink -realPath $link.source -symlinkPath $link.destination
}
