# Vanilla WP playground

A blank-ish WordPress setup for developing and testing my base configuration, plugins, and theme framework.

Specifically:
- [Comet Components](https://github.com/doubleedesign/comet-components/)
- [Breadcrumbs](https://github.com/doubleedesign/doublee-breadcrumbs)
- [Base plugin](https://github.com/doubleedesign/doublee-base-plugin)

Local versions of plugins are symlinked, with the script `symlinks.ps1` to create or update them assuming the following:
- This repository is cloned to `C:\Users\{username}\LocalSites\vanilla-playground`
- Plugins to be symlinked are cloned into `C:\Users\{username}\PHPStormProjects\{plugin-name}`

To create or update the symlinks, in Powershell with admin privileges run:
```PowerShell
.\symlinks.ps1
```

Or in WSL1 Bash (also run with admin privileges):
```bash
powershell.exe -File symlinks.ps1
```
