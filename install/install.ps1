<#
.SYNOPSIS
    Installs SpotPalette (patched Command Palette) from this folder.

.DESCRIPTION
    1. Trusts SpotPalette.cer (Local Machine > Trusted People). The certificate was created
       for this build only; its private key was discarded, so it cannot sign anything else.
    2. Installs SpotPalette.msix with Windows' built-in package installer.
    Requires administrator rights for step 1. Nothing else is downloaded or installed.
#>
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Requesting administrator rights...'
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    return
}

try {
    $cer = Join-Path $here 'SpotPalette.cer'
    $msix = Join-Path $here 'SpotPalette.msix'

    Write-Host 'Trusting the SpotPalette certificate...'
    Import-Certificate -FilePath $cer -CertStoreLocation Cert:\LocalMachine\TrustedPeople | Out-Null

    Write-Host 'Installing SpotPalette...'
    Add-AppxPackage -Path $msix -ForceUpdateFromAnyVersion -ForceApplicationShutdown

    # Start it once now: Windows only activates the "start with Windows" task after the
    # app has been launched by the user at least once.
    $package = Get-AppxPackage -Name 'Microsoft.CommandPalette.Dev' |
        Where-Object { $_.Publisher -eq 'CN=SpotPalette' } | Select-Object -First 1
    if ($package) {
        $appId = (Get-AppxPackageManifest $package).Package.Applications.Application.Id
        Start-Process "shell:AppsFolder\$($package.PackageFamilyName)!$appId"
    }

    Write-Host ''
    Write-Host 'Installed and started. It will also start automatically when Windows starts.' -ForegroundColor Green
    Write-Host 'Open it with its shortcut, or "Command Palette (Dev)" in the Start menu.'
    Write-Host 'Settings > Appearance > How Command Palette opens > Spotlight search bar.'
    Write-Host 'To stop it starting with Windows: Settings > Apps > Startup.'
    Write-Host 'If the official Command Palette is also installed, change the shortcut of one of them.'
}
catch {
    Write-Host "Installation failed: $_" -ForegroundColor Red
}

Read-Host 'Press Enter to close'
