<#
.SYNOPSIS
    Saves your Command Palette changes from the PowerToys folder back into patches\.

.DESCRIPTION
    Use this after editing the code in the folder created by setup.ps1. It writes every
    change under src\modules\cmdpal (committed or not, new files included) relative to the
    upstream commit recorded by setup.ps1 into a single patch file, replacing the existing
    patches. Commit the result in this repository.

.PARAMETER Source
    The PowerToys folder created by setup.ps1. Defaults to a "PowerToys" folder next to this repo.

.PARAMETER Name
    File name of the patch to write.
#>
[CmdletBinding()]
param(
    [string]$Source,
    [string]$Name = '0001-cmdpal-spotlight-search-bar-style.patch'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not $Source) {
    $Source = Join-Path (Split-Path $repoRoot -Parent) 'PowerToys'
}

$base = (& git -C $Source config spotpalette.base)
if ($LASTEXITCODE -ne 0 -or -not $base) {
    throw "$Source was not created by scripts\setup.ps1 (spotpalette.base is not set)."
}

# Include new, untracked files in the diff.
& git -C $Source add --intent-to-add -- src/modules/cmdpal
if ($LASTEXITCODE -ne 0) { throw 'git add --intent-to-add failed' }

$patchDir = Join-Path $repoRoot 'patches'
$tmp = New-TemporaryFile

# Let git write the file itself: piping through PowerShell would rewrite line endings.
& git -C $Source diff --binary "--output=$($tmp.FullName)" $base -- src/modules/cmdpal
if ($LASTEXITCODE -ne 0) { throw 'git diff failed' }

if ((Get-Item $tmp).Length -eq 0) {
    Remove-Item $tmp
    throw "No changes under src/modules/cmdpal since $base."
}

Get-ChildItem $patchDir -Filter '*.patch' | Remove-Item
Move-Item $tmp (Join-Path $patchDir $Name)

$upstreamFile = Join-Path $repoRoot 'UPSTREAM_COMMIT'
Set-Content -Path $upstreamFile -Value $base -Encoding ascii
Write-Host "Wrote patches\$Name (base $base)."
