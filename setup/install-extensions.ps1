#Requires -Version 5.1
<#
.SYNOPSIS
  Installiert alle VSCode-Extensions der UML-Diagram-Suite.

.DESCRIPTION
  Liest templates\.vscode\extensions.json (Single Source of Truth)
  und installiert jede Extension via VSCode CLI.
  Skippt bereits installierte Extensions (idempotent).

.PARAMETER Force
  Re-Installiert alle Extensions, auch wenn schon vorhanden.

.EXAMPLE
  .\install-extensions.ps1
  .\install-extensions.ps1 -Force
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$setupDir    = $PSScriptRoot
$suiteRoot   = Split-Path $setupDir -Parent
$extJsonPath = Join-Path $suiteRoot "templates\.vscode\extensions.json"

Write-Host ""
Write-Host "=== UML-Diagram-Suite: Extensions installieren ===" -ForegroundColor Cyan
Write-Host ""

# ----- VSCode CLI finden -----
$codeCmdCandidates = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd"
)
$codeCmd = $codeCmdCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $codeCmd) {
    Write-Host "FEHLER: VSCode CLI (code.cmd) nicht gefunden." -ForegroundColor Red
    $codeCmdCandidates | ForEach-Object { Write-Host "  geprueft: $_" -ForegroundColor Red }
    exit 1
}
Write-Host "VSCode CLI: $codeCmd" -ForegroundColor DarkGray

# ----- extensions.json laden -----
if (-not (Test-Path $extJsonPath)) {
    Write-Host "FEHLER: $extJsonPath nicht gefunden." -ForegroundColor Red
    exit 1
}
$extensions = (Get-Content $extJsonPath -Raw | ConvertFrom-Json).recommendations
Write-Host "Quelle:     $extJsonPath ($($extensions.Count) Extensions)" -ForegroundColor DarkGray
Write-Host ""

# ----- Bereits installierte ermitteln -----
Write-Host "Lade installierte Extensions..." -ForegroundColor DarkGray
$installed = & $codeCmd --list-extensions
Write-Host ""

# ----- Installation -----
$installedCount = 0; $skippedCount = 0; $failed = @()

foreach ($ext in $extensions) {
    if (($installed -contains $ext) -and -not $Force) {
        Write-Host "[SKIP]    $ext" -ForegroundColor DarkGray
        $skippedCount++
        continue
    }
    Write-Host "[INSTALL] $ext" -ForegroundColor Yellow
    & $codeCmd --install-extension $ext --force | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $installedCount++
    } else {
        Write-Host "  -> FEHLGESCHLAGEN (Exit $LASTEXITCODE)" -ForegroundColor Red
        $failed += $ext
    }
}

# ----- Zusammenfassung -----
Write-Host ""
Write-Host "=== Zusammenfassung ===" -ForegroundColor Cyan
Write-Host "  Installiert:     $installedCount" -ForegroundColor Green
Write-Host "  Uebersprungen:   $skippedCount"   -ForegroundColor DarkGray
$failColor = if ($failed.Count) { 'Red' } else { 'DarkGray' }
Write-Host "  Fehlgeschlagen:  $($failed.Count)" -ForegroundColor $failColor

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Fehlgeschlagene Extensions:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
exit 0
