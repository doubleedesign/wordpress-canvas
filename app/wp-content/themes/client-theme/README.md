# Double-E Design client theme boilerplate

This is a template for a child theme of Comet Canvas, intended for use with Double-E Design's base suite of plugins.

It is intended to manage visual look and feel, including menus. For custom post types and taxonomies, create [a client plugin](https://github.com/doubleedesign/wp-plugin-template).

## Setup

Upon first use, run `./setup.ps1` from this the `wp-content/themes/client-theme` directory:

```powershell
./setup.ps1
```

This will:
- Update "Client Name" everywhere to the actual client name
- Install dependencies (PNPM and Composer)
- Ensure Composer autoloader is up-to-date
- Delete the setup file and this README
- Rename the folder to the client name.
