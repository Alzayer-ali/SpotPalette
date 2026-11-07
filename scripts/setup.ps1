<#
.SYNOPSIS
    Downloads PowerToys at the pinned commit and applies the SpotPalette patches.

.DESCRIPTION
    Fetches microsoft/PowerToys (shallow, one commit) into -Destination, checks out a
    local "spotpalette" branch and applies every file in ..\patches in name order. Each
    patch is applied to the index and then checked out, so Git converts line endings
    exactly as upstream's .gitattributes expects (CRLF for .cs files).

    After it finishes, open src\modules\cmdpal\CommandPalette.slnf in Visual Studio,
    then Build and Deploy the Microsoft.CmdPal.UI project.

.PARAMETER Destination
    Folder for the PowerToys source. Defaults to a "PowerToys" folder next to this repo.

.PARAMETER Latest
    Use the newest upstream main instead of the pinned commit in UPSTREAM_COMMIT.
    The patches may then need fixing if upstream changed the same lines.

.PARAMETER OpenVisualStudio
    Open CommandPalette.slnf when done.

.EXAMPLE
    .\scripts\setup.ps1 -OpenVisualStudio
#>
[CmdletBinding()]
param(
    [string]$Destination,
    [switch]$Latest,
    [switch]$OpenVisualStudio
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not $Destination) {
    $Destination = Join-Path (Split-Path $repoRoot -Parent) 'PowerToys'
}

$upstreamUrl = 'https://github.com/microsoft/PowerToys.git'
$pinnedCommit = (Get-Content (Join-Path $repoRoot 'UPSTREAM_COMMIT') -Raw).Trim()
$patches = @(Get-ChildItem (Join-Path $repoRoot 'patches') -Filter '*.patch' | Sort-Object Name)

function Invoke-Git {
    & git @args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($args -join ' ') failed with exit code $LASTEXITCODE"
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed or not on PATH. Install it from https://git-scm.com/ and try again.'
}

if (-not (Test-Path (Join-Path $Destination '.git'))) {
    Write-Host "Creating $Destination"
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Invoke-Git -C $Destination init -q
    Invoke-Git -C $Destination remote add origin $upstreamUrl
}
else {
    $dirty = & git -C $Destination status --porcelain
    if ($dirty) {
        throw "$Destination has uncommitted changes. Commit them, run scripts\export-patch.ps1, or choose another -Destination."
    }
}

# PowerToys has deep paths; avoid "Filename too long" on Windows.
Invoke-Git -C $Destination config core.longpaths true

$ref = if ($Latest) { 'main' } else { $pinnedCommit }
Write-Host "Fetching PowerToys ($ref)... this can take a few minutes the first time."
Invoke-Git -C $Destination fetch --depth 1 origin $ref
Invoke-Git -C $Destination checkout -q -B spotpalette FETCH_HEAD

$baseCommit = (& git -C $Destination rev-parse HEAD).Trim()
Invoke-Git -C $Destination config spotpalette.base $baseCommit

foreach ($patch in $patches) {
    Write-Host "Applying $($patch.Name)"
    & git -C $Destination apply --cached $patch.FullName
    if ($LASTEXITCODE -ne 0) {
        Invoke-Git -C $Destination reset -q --hard $baseCommit
        $hint = if ($Latest) { ' Upstream changed the same code; run without -Latest to use the pinned commit.' } else { '' }
        throw "$($patch.Name) does not apply to $baseCommit.$hint"
    }

    # Write the patched index to disk, converting line endings per .gitattributes.
    Invoke-Git -C $Destination checkout -- .
    Invoke-Git -C $Destination -c user.name=SpotPalette -c user.email=spotpalette@users.noreply.github.com commit -q -m "SpotPalette: $($patch.BaseName)"
}

$slnf = Join-Path $Destination 'src\modules\cmdpal\CommandPalette.slnf'
Write-Host ''
Write-Host 'Done. Next steps:' -ForegroundColor Green
Write-Host "  1. Open $slnf in Visual Studio (Debug, x64 or ARM64)."
Write-Host '  2. Right-click Microsoft.CmdPal.UI > Build, then Deploy.'
Write-Host '  3. Launch Command Palette from the Start menu, then Settings > Appearance >'
Write-Host '     "How Command Palette opens" > "Spotlight search bar".'

if ($OpenVisualStudio) {
    Start-Process $slnf
}
