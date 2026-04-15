# Troubleshooting

**Getting published Double-E Design packages instead of local symlinks**

Ensure you set `$ENV:COMPOSER = "composer.dev.json"` before running `composer install` or `composer update` to use the local symlinks. If you don't set this environment variable, it will default to using `composer.json`, which references the published versions of the packages.
---

```
No composer.json in current directory
```
If you get this error when trying to update dependencies or the autoloader in a local package in the same session that you set the `COMPOSER` environment variable to point to `composer.dev.json`, you can either close the PowerShell session and open a new one, or set it back:

```powershell
$ENV:COMPOSER = "composer.json"
```
...then try your command again.

---
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

---

```
Unhandled exception. System.Management.Automation.PSSecurityException: postinstall.ps1 cannot be loaded because running scripts is disabled on this system.
```

First you can check the current execution policy with:
```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

Set it to `Bypass` to allow running scripts without restrictions:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

To disable it again when you're done, you can run the following (replacing `Restricted` with the previous value if it was different):

```powershell
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
```
