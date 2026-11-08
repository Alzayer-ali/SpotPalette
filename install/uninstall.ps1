# Removes SpotPalette and the certificate that install.ps1 trusted.
$ErrorActionPreference = 'Continue'
Get-AppxPackage -Name 'Microsoft.CommandPalette.Dev' |
    Where-Object { $_.Publisher -eq 'CN=SpotPalette' } |
    Remove-AppxPackage
Write-Host 'SpotPalette removed.'

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Get-ChildItem Cert:\LocalMachine\TrustedPeople | Where-Object { $_.Subject -eq 'CN=SpotPalette' } | Remove-Item
    Write-Host 'Certificate removed.'
}
else {
    Write-Host 'Run this script as administrator to also remove the SpotPalette certificate.'
}
