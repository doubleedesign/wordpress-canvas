# My Project Name

A [Composer](https://getcomposer.org/)-managed WordPress site project for [Client Name].

The below instructions are written for Windows users with PowerShell as the CLI. Adjust accordingly if required.

- [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [Install/update dependencies](#installupdate-dependencies)
  - [Local database](#local-database)
  - [Optional: Double-E Design dev mode](#optional-double-e-design-dev-mode)
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

To install or update dependencies, run the following commands in the project root and in each of the project's theme and custom plugin(s):

```powershell
composer install
```
```powershell
composer update
```

In the theme and custom plugin(s) you will also need to install JavaScript dependencies if a `package.json` file is present:

```powershell
npm install
```

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

### Optional: Double-E Design dev mode

This project uses multiple packages developed by [Double-E Design](https://www.doubleedesign.com.au). You can optionally use local copies of those repositories (if you already have them cloned) like so:

```powershell
$env:COMPOSER = "composer.dev.json"; composer install
```
```powershell
$env:COMPOSER = "composer.dev.json"; composer update
```
This will temporarily set the `COMPOSER` environment variable to point to the `composer.dev.json` file, which will persist for the duration of your PowerShell session.

> [!WARNING]  
> Do not deploy the `doublee-local-dev` plugin to staging or production sites. It is intended only for local development and may break things and/or pose security risks on live sites.

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
