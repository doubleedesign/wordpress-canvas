# Double-E Design WordPress Canvas

A [Composer](https://getcomposer.org/)-managed blank-ish WordPress setup for developing and testing my base configuration, plugins, and theme framework; and for starting a new WordPress or ClassicPress project.

Specifically:
- [Comet Components](https://github.com/doubleedesign/comet-components/) (Blocks plugin, Calendar plugin, parent theme for the block editor)
- [Breadcrumbs](https://github.com/doubleedesign/doublee-breadcrumbs)
- [Base plugin](https://github.com/doubleedesign/doublee-base-plugin)
- [ACF Advanced Image Field](https://github.com/doubleedesign/acf-advanced-image-field)
- [TinyMCE plugins and customisation](https://github.com/doubleedesign/doublee-tinymce)
- [Ninja Forms markup and styling](https://github.com/doubleedesign/doublee-ninja-markup)

Local copies of the above plugins and parent theme are symlinked by the Composer installation process, enabling straightforward Git-integrated development (I have found this setup easier to work with than Git submodules).Other plugins I commonly use (e.g. the free/base versions of [Ninja Forms](https://wordpress.org/plugins/ninja-forms/), [Simply Disable Comments](https://wordpress.org/plugins/simply-disable-comments/), and [The SEO Framework](https://github.com/sybrew/the-seo-framework)) are also installed when running `composer install` or `composer update`. 

---
## Table of Contents
- [Prerequisites](#prerequisites)
- [Automated setup](#automated-setup)
- [Manual setup](#manual-setup)
- [Using this repo as a project template](#using-this-repo-as-a-project-template)
- [Additional Resources](#additional-resources)

---
## Prerequisites
- Local development environment with PHP, Composer, MySQL, and Node (e.g., [Laravel Herd Pro](https://herd.laravel.com/))
- [Laravel Pint](https://laravel.com/docs/12.x/pint) installed globally and configured to run on save in your IDE in the individual projects
- [Sass](https://sass-lang.com/install) installed globally and configured to run on save in your IDE for the individual projects that use it
- [Advanced Custom Fields Pro](https://www.advancedcustomfields.com/pro/) licence

To install Pint globally: 
```php
composer global require laravel/pint
```
To install Sass globally with [Chocolatey](https://chocolatey.org/):
```powershell
choco install sass
```

## Automated setup

1. Clone this repository into the same directory as the above-listed projects
2. Ensure you have [WP CLI](https://wp-cli.org/) installed and available in your system PATH
3. Ensure ACF Pro is stored in your `PhpStormProjects` directory (or update the setup script)
4. Update the setup script if your MySQL server is not on port 3309 (the default is 3306)
5. Update the setup script if you want to use different database and/or WordPress credentials

> [!IMPORTANT]  
> If you are using this repo as a project template, follow the [instructions](#using-this-repo-as-a-project-template) below about that before running the setup script.

5. Run the PowerShell script from the project root:

```powershell
./setup.ps1
```

This will:
1. Install/update Composer dependencies (unless you elect not to)
2. Copy ACF Pro from `C:/Users/YOUR_USERNAME/PhpStormProjects/advanced-custom-fields-pro` into the `app/wp-content/plugins` directory
3. Delete any default themes (anything starting with `twenty`)
4. Delete Hello Dolly and Akismet plugins if they are present
5. Create a database matching your project directory name, if it doesn't already exist
6. Import the latest copy of the database dump located in this project's `sql` folder, if available (unless you elect not to)
7. Check if WordPress is installed in that database, and install it if not
8. Activate the Comet Canvas theme
9. Activate the plugins installed via Composer, in the appropriate order accounting for known dependencies
10. Link the site in Laravel Herd and secure it with a local SSL cert
11. Open the site admin in your default browser.

All going well, the only thing you will need to do manually is enter your ACF Pro licence key.

> [!NOTE]  
> If you update the data in the test site, you can automatically export the database and commit it to Git when you're done using the automated packup script: `./packup.ps1`.

## Manual setup
1. Clone this repository into the same directory as the above-listed projects 
2. if using local copies of the above-listed plugins, ensure they are up-to-date with local Composer configuration and dependencies in each project directory. (Remove `--no-dev` if you also intend to do things like unit testing in those projects.)
	
    ```powershell
     $env:COMPOSER = "composer.local.json"; composer update --prefer-source --no-dev
    composer dump-autoload -o
    ```
	
    If a project does not have a `composer.local.json` file, close the terminal window and open a new one (to clear the temporary environment variable) before running the basic commands:
	
    ```powershell
    composer update --prefer-source --no-dev
    composer dump-autoload -o
    ```
3. Create a database matching the config provided in `wp-config.php` (or update the config)
4. Import the latest copy of the database dump located in this project's `sql` folder
5. Install WordPress core and symlink the local plugin and theme projects
    ```powershell
    composer install
    ```
6. Copy ACF Pro into the `app/wp-content/plugins` directory (not included in this repo for licensing reasons)
7. If using Laravel Herd, add and secure the site either through the UI or in your terminal with:
    ```powershell
    cd app
    herd link wordpress-canvas
    herd secure
    ```
8. Access the site admin at [https://wordpress-canvas.test/wp-admin](https://wordpress-canvas.test/wp-admin) (or whatever URL your local environment uses), activate the theme and plugins, and enter your ACF Pro licence key
9. Delete unwanted default themes and plugins.

In the plugin/theme projects you intend to edit:
1. If the project has a `composer.json` file, run `composer install` 
2. If the project has a `package.json` file, run `npm install`
3. In your IDE config, set the WordPress installation path (PHP → Frameworks in PhpStorm) to this project's `app` folder
4. Refer to project README files for further setup and development instructions (e.g., asset compiling).
5. If you update the data in the test site, you can manually export the database and commit it to Git when you're done, or use the automated script as described above.

---
## Using this repo as a project template

1. Remove the `.git` folder, rename the project directory, and run `git init` to initialise it as a new repository.
2. Update the `composer.json` file to reflect your new project details and run `composer update` to regenerate the `composer.lock` file.
3. Update the folder name and metadata (in `style.scss`) for the child theme to suit your new project.
4. Ensure Laravel Pint and Sass are set up to run on save for the child theme.
5. If your project will contain custom post types, taxonomies, and other data-related functionality, create a project-specific plugin.
6. Ensure your custom theme, any custom plugins, and any plugins not managed by Composer are not excluded from version control by updating the `.gitignore` file as necessary.

> [!WARNING]  
> Do not deploy the `doublee-local-dev` plugin to staging or production sites. It is intended only for local development and may break things and/or pose security risks on live sites.

---
## Additional Resources
- [Comet Components docs](https://cometcomponents.io)
- [My WordPress plugin template](https://github.com/doubleedesign/wp-plugin-template)
- [WP Packagist](https://wpackagist.org/) - use to install WP.org-listed plugins via Composer

---
## Troubleshooting

```
The Herd Desktop application is not running. Please start Herd and try again.
```
If you get this error and Herd is definitely running, something else may be using the port that Herd uses to communicate with the CLI (usually 9001). You can confirm in Herd under General → Internal API Port.

To find what is using the port, open a PowerShell instance with admin privileges and run:

```powershell
netstat -aon | findstr :9001
```
If it's something you can't stop, you can change the port Herd uses in the settings and stop and restart all services in Herd to work around it.

If nothing comes up, you can also try changing the port in Herd and restarting all services; if that doesn't work try exiting Herd completely and restarting it.
