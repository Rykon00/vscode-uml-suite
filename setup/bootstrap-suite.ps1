#Requires -Version 5.1
<#
.SYNOPSIS
  Synchronisiert die UML-Suite-Settings + Snippets in die globalen
  VSCode User-Settings (Default-Profile).

.DESCRIPTION
  Idee: "git pull && bootstrap" - holt den aktuellen Stand aus dem Repo
  und macht VSCode global UML-ready.

  Aktionen:
    1. Backup der bestehenden globalen User-Settings
    2. Snippets nach %APPDATA%\Code\User\snippets\ kopieren
    3. Settings in %APPDATA%\Code\User\settings.json mergen (Default)
       oder ersetzen (bei -Mode Replace)
    4. Extensions aus templates/.vscode/extensions.json installieren
       (idempotent, ueberspringt vorhandene)

  Standardmodus: Merge.
  Mit "-Mode Replace" werden vorhandene Settings ueberschrieben.

.PARAMETER Mode
  Merge   : Bestehende Settings bleiben, UML-Keys werden ergaenzt/ueberschrieben (Default)
  Replace : Komplette globale Settings werden durch Suite-Settings ersetzt

.PARAMETER SkipExtensions
  Extensions-Installation auslassen (z.B. wenn nur Settings refreshed werden sollen).

.EXAMPLE
  .\bootstrap-suite.ps1
  .\bootstrap-suite.ps1 -Mode Replace
  .\bootstrap-suite.ps1 -SkipExtensions
#>

[CmdletBinding()]
param(
    [ValidateSet('Merge', 'Replace')]
    [string]$Mode = 'Merge',
    [switch]$SkipExtensions
)

$ErrorActionPreference = 'Stop'

$setupDir   = $PSScriptRoot
$suiteRoot  = Split-Path $setupDir -Parent
$templateVscode = Join-Path $suiteRoot "templates\.vscode"

# VSCode User-Pfade (Stable; fuer Insiders waere es "Code - Insiders")
$userDir         = Join-Path $env:APPDATA "Code\User"
$userSettings    = Join-Path $userDir "settings.json"
$userSnippetsDir = Join-Path $userDir "snippets"

Write-Host ""
Write-Host "=== UML-Suite: Bootstrap in Default-Profile ===" -ForegroundColor Cyan
Write-Host "Modus: $Mode" -ForegroundColor DarkGray
Write-Host "Ziel:  $userDir" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-Path $userDir)) {
    Write-Host "FEHLER: $userDir existiert nicht. Ist VSCode installiert + mind. einmal gestartet?" -ForegroundColor Red
    exit 1
}

# ============================================================
# 1) Backup
# ============================================================
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $userDir "backup-pre-uml-suite-$timestamp"
Write-Host "[1/4] Backup nach $backupDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

if (Test-Path $userSettings) {
    Copy-Item $userSettings (Join-Path $backupDir "settings.json")
    Write-Host "      settings.json gesichert" -ForegroundColor DarkGray
}
if (Test-Path $userSnippetsDir) {
    Copy-Item $userSnippetsDir (Join-Path $backupDir "snippets") -Recurse
    Write-Host "      snippets\ gesichert" -ForegroundColor DarkGray
}
Write-Host "[OK] Backup erstellt" -ForegroundColor Green
Write-Host ""

# ============================================================
# 2) Snippets kopieren (nicht-kollidierend, einfach Datei rueber)
# ============================================================
Write-Host "[2/4] Snippets installieren..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $userSnippetsDir -Force | Out-Null

$srcSnippets = Get-ChildItem (Join-Path $templateVscode "snippets") -File -ErrorAction SilentlyContinue
foreach ($snip in $srcSnippets) {
    $dest = Join-Path $userSnippetsDir $snip.Name
    Copy-Item $snip.FullName $dest -Force
    Write-Host "      $($snip.Name) -> User-Snippets" -ForegroundColor DarkGray
}
Write-Host "[OK] $($srcSnippets.Count) Snippet-File(s) installiert" -ForegroundColor Green
Write-Host ""

# ============================================================
# 3) Settings (Merge oder Replace)
# ============================================================
Write-Host "[3/4] Settings ($Mode)..." -ForegroundColor Yellow

# Template-Settings laden (mit Kommentar-Stripping fuer JSON-Parser)
$templateSettingsPath = Join-Path $templateVscode "settings.global.json"
if (-not (Test-Path $templateSettingsPath)) {
    Write-Host "FEHLER: Template-Settings fehlen unter $templateSettingsPath" -ForegroundColor Red
    exit 1
}
$templateRaw = Get-Content $templateSettingsPath -Raw
# JSON-mit-Kommentaren -> Kommentare entfernen, damit ConvertFrom-Json klappt
$templateClean = $templateRaw `
    -replace '(?ms)/\*.*?\*/', '' `
    -replace '(?m)^\s*//.*$', ''
$templateObj = $templateClean | ConvertFrom-Json

if ($Mode -eq 'Replace') {
    # Komplett ersetzen (Backup haben wir oben gemacht)
    $templateObj | ConvertTo-Json -Depth 10 | Set-Content $userSettings -Encoding UTF8
    Write-Host "[OK] Globale Settings KOMPLETT ersetzt" -ForegroundColor Green
} else {
    # Merge: bestehende Settings laden, Suite-Keys drueberschreiben
    $existing = @{}
    if (Test-Path $userSettings) {
        $existingRaw = Get-Content $userSettings -Raw
        $existingClean = $existingRaw `
            -replace '(?ms)/\*.*?\*/', '' `
            -replace '(?m)^\s*//.*$', ''
        if ($existingClean.Trim()) {
            $obj = $existingClean | ConvertFrom-Json
            $obj.PSObject.Properties | ForEach-Object { $existing[$_.Name] = $_.Value }
        }
    }

    # Suite-Keys ueber bestehende drueberschreiben
    $overwritten = @()
    $added = @()
    $templateObj.PSObject.Properties | ForEach-Object {
        if ($existing.ContainsKey($_.Name)) { $overwritten += $_.Name } else { $added += $_.Name }
        $existing[$_.Name] = $_.Value
    }

    # Hashtable zurueck nach JSON
    $merged = [PSCustomObject]$existing
    $merged | ConvertTo-Json -Depth 10 | Set-Content $userSettings -Encoding UTF8

    Write-Host "[OK] Settings gemerged" -ForegroundColor Green
    Write-Host "      Neu hinzugefuegt:    $($added.Count) Keys" -ForegroundColor DarkGray
    Write-Host "      Ueberschrieben:      $($overwritten.Count) Keys" -ForegroundColor DarkGray
    if ($overwritten.Count -gt 0) {
        Write-Host "      (Backup: $backupDir\settings.json)" -ForegroundColor DarkGray
    }
}
Write-Host ""

# ============================================================
# 4) Extensions
# ============================================================
if ($SkipExtensions) {
    Write-Host "[4/4] Extensions: uebersprungen (-SkipExtensions)" -ForegroundColor DarkGray
} else {
    Write-Host "[4/4] Extensions installieren..." -ForegroundColor Yellow
    $installScript = Join-Path $setupDir "install-extensions.ps1"
    if (Test-Path $installScript) {
        & $installScript
    } else {
        Write-Host "      install-extensions.ps1 nicht gefunden - skip" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Bootstrap fertig ===" -ForegroundColor Cyan
Write-Host "Backup-Ordner: $backupDir" -ForegroundColor DarkGray
Write-Host "Bei Problemen: Files aus dem Backup-Ordner zurueckkopieren." -ForegroundColor DarkGray
Write-Host ""
exit 0

