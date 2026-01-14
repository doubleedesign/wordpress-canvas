# Double-E Design WordPress Canvas

A blank-ish WordPress setup for developing and testing my base configuration, plugins, and theme framework; and for starting a new WordPress or ClassicPress project.

Specifically:
- [Comet Components](https://github.com/doubleedesign/comet-components/) (Blocks plugin, Calendar plugin, parent theme for the block editor)
- [Breadcrumbs](https://github.com/doubleedesign/doublee-breadcrumbs)
- [Base plugin](https://github.com/doubleedesign/doublee-base-plugin)
- [ACF Advanced Image Field](https://github.com/doubleedesign/acf-advanced-image-field)
- [TinyMCE plugins and customisation](https://github.com/doubleedesign/doublee-tinymce)
- [Ninja Forms markup and styling](https://github.com/doubleedesign/doublee-ninja-markup)

Local copies of the above plugins and parent theme plus some other plugins I commonly use (e.g. the free/base versions of [Ninja Forms](https://wordpress.org/plugins/ninja-forms/) and [The SEO Framework](https://github.com/sybrew/the-seo-framework)) are symlinked by the Composer installation process, enabling straightforward Git-integrated development (I have found this setup easier to work with than Git submodules). 

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

## Setup
1. Clone this repository into the same directory as the above-listed projects 
2. Create a database matching the config provided in `wp-config.php` (or update the config)
3. Import the latest copy of the database dump located in this project's `sql` folder
4. Install WordPress core and symlink the local plugin and theme projects
	```powershell
	composer install
	```
5. Copy ACF Pro into the `app/wp-content/plugins` directory (not included in this repo for licensing reasons)
6. If using Laravel Herd, add and secure the site either through the UI or in your terminal with:
	```powershell
	cd app
	herd link wordpress-canvas
	herd secure
	```
7. Access the site admin at [https://wordpress-canvas.test/wp-admin](https://wordpress-canvas.test/wp-admin) (or whatever URL your local environment uses), activate the theme and plugins, and enter your ACF Pro licence key.

In the plugin/theme projects you intend to edit:
1. If the project has a `composer.json` file, run `composer install` 
2. If the project has a `package.json` file, run `npm install`
3. In your IDE config, set the WordPress installation path (PHP → Frameworks in PhpStorm) to this project's `app` folder
4. Refer to project README files for further setup and development instructions (e.g., asset compiling).

## Using this repo as a project template

1. Remove the `.git` folder, rename the project directory, and run `git init` to initialise it as a new repository.
2. Update the `composer.json` file to reflect your new project details and run `composer update` to regenerate the `composer.lock` file.
3. Update the folder name and metadata (in `style.scss`) for the child theme to suit your new project.
4. Ensure Laravel Pint and Sass are set up to run on save for the child theme.
5. If your project will contain custom post types, taxonomies, and other data-related functionality, create a project-specific plugin.

> [!WARNING]  
> Do not deploy the `doublee-local-dev` plugin to staging or production sites. It is intended only for local development and may break things and/or pose security risks on live sites.

## Additional Resources
- [Comet Components docs](https://cometcomponents.io)
- [My WordPress plugin template](https://github.com/doubleedesign/wp-plugin-template)
- [WP Packagist](https://wpackagist.org/) - use to install WP.org-listed plugins via Composer
