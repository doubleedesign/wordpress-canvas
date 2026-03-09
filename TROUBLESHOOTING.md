# Troubleshooting

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
