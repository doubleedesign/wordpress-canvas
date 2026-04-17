# My Project Name

A [Composer](https://getcomposer.org/)-managed WordPress site project for [Client Name].

The below instructions are written for Windows users with PowerShell as the CLI. Adjust accordingly if required.

- [Setup](#setup)
	- [Prerequisites](#prerequisites)
	- [Install/update dependencies](#installupdate-dependencies)
	- [Optional: Double-E Design dev mode](#optional-double-e-design-dev-mode)
	- [Local database](#local-database)
- [Packup](#packup)
- [Additional Resources](#additional-resources)
- [Troubleshooting](#troubleshooting)

## Setup

### Prerequisites
- Local development environment with PHP, Composer, MySQL, and Node (e.g., [Laravel Herd Pro](https://herd.laravel.com/))
- [Laravel Pint](https://laravel.com/docs/12.x/pint) installed globally and configured to run on save in your IDE
- [Sass](https://sass-lang.com/install) installed globally and configured to run on save in your IDE.

  To install Pint globally:
```powershell
composer global require laravel/pint
```

To install Sass globally with [Chocolatey](https://chocolatey.org/):
```powershell
choco install sass
```

### Install/update dependencies

Dependency installation/updates (both Composer and NPM) are largely handled via automated scripts. These also automatically handle using Double-E Design dev mode (described below).

When starting work on a new local copy of this project, or if you haven't worked on it for a while, start with the setup script. There is no need to set the dev environment variable - this one will prompt you. This handles installing WordPress and all dependencies in the project root's `composer.json` (or `composer.dev.json` if you select dev mode), and generates a PhpStorm meta file in the project root listing the action and filter hooks from Double-E Design's packages to enable autocompletion for them.

```powershell
./setup.ps1
```

To only refresh dependencies in themes and selected plugins, use the post-install script. If you want to use dev mode, set the `POWERPRESS_DEV` environment variable first.

To only regenerate the PhpStorm meta file, run `./update-phpstorm-meta.ps1` directly.

```powershell
$env:POWERPRESS_DEV = 1; ./postinstall.ps1
```

> [!NOTE]
> The setup script _also_ runs the postinstall script inside it. You do not generally need to run both individually.

> [!IMPORTANT]
> If you have client-specific plugins, you may need to update their dependencies separately if the script(s) have not been updated to account for them.

### Optional: Double-E Design dev mode

This project uses multiple packages developed by [Double-E Design](https://www.doubleedesign.com.au). You can optionally use local copies of those repositories (if you already have them cloned) by creating a copy of `composer.json` called `composer.dev.json` that references their local locations and specifies to symlink them.

If `composer.dev.json` does not already exist, you can find an example in the [WordPress Canvas](https://github.com/doubleedesign/wordpress-canvas) repository.

To use it:

```powershell
$env:COMPOSER = "composer.dev.json"; composer install
```
```powershell
$env:COMPOSER = "composer.dev.json"; composer update
```
This will temporarily set the `COMPOSER` environment variable to point to the `composer.dev.json` file, which will persist for the duration of your PowerShell session.

You can also update the dependencies of your local copies of the Double-E Design packages from their source directories as needed using the `postinstall.ps1` script, setting dev mode first:

```powershell
$env:POWERPRESS_DEV = 1; ./postinstall.ps1
```

> [!IMPORTANT]
> This script skips dev dependencies in the local copies of the Double-E Design packages, so that the version you're working on is ok to upload to production - it won't take things like unit testing dependencies with it. If you need to use those while working on this project, you can run `composer install` or `composer update` in the local copy of the package you're working on, and then do it again with `--no-dev` to remove the dev dependencies before deploying.

> [!WARNING]  
> Do not deploy the `doublee-local-dev` plugin to staging or production sites. It is intended only for local development and may break things and/or pose security risks on live sites.

### Local database

For a fresh local setup:

1. Update the database credentials in the `wp-config.php` file to match your local MySQL/MariaDB instance.
2. Create a database for the site in your local MySQL/MariaDB instance. In [Laravel Herd Pro](https://herd.laravel.com/), you can ensure the database service is set up and running in the **Services** tab.

3. If using WP-CLI:

   i. Import the database from the command line with:
   ```powershell
   wp db import path/to/backup.sql
   ```

ii. Do a find-and-replace with WP-CLI to update the site URL to match your local development URL:
```powershell
wp search-replace 'http://oldsiteurl.com' 'https://myproject.test' --skip-columns=guid
```

4. If not using WP-CLI:

   i. Do a find-and-replace in the SQL backup file to update the site URL to match your local development URL.
   ii. Access the web interface (via the Services screen in Herd Pro) to import the SQL file into your local database.

--- 
## Packup
To export the local dev database and commit it to Git, run the following command in the project root:

```powershell
./packup.ps1
```

Also ensure you commit any code and config changes to the repo.

---
## Additional Resources
- [Comet Components docs](https://cometcomponents.io)
- [Double-E Design's WordPress plugin template](https://github.com/doubleedesign/wp-plugin-template)
- [WP Packagist](https://wpackagist.org/) - use to install WP.org-listed plugins via Composer

---
## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for solutions to common issues.
