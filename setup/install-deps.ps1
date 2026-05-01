#Requires -Version 5.1
<#
.SYNOPSIS
  Installiert alle System-Dependencies fuer die UML-Diagram-Suite.

.DESCRIPTION
  Prueft und installiert (falls fehlend):
    - Java JRE 17+ (Microsoft.OpenJDK.21 via winget)
    - Graphviz             (Graphviz.Graphviz   via winget)
    - plantuml.jar         (Direkt-Download von GitHub Releases)

  Skript ist idempotent: Mehrfaches Ausfuehren ist sicher.

.PARAMETER Force
  Erzwingt Re-Download der plantuml.jar (System-Pakete bleiben unangetastet).

.EXAMPLE
  .\install-deps.ps1
  .\install-deps.ps1 -Force
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Skript-Standort als Anker (funktioniert egal von wo aufgerufen)
$setupDir = $PSScriptRoot
$jarPath  = Join-Path $setupDir "plantuml.jar"

Write-Host ""
Write-Host "=== UML-Diagram-Suite: Dependencies installieren ===" -ForegroundColor Cyan
Write-Host ""

# ----- 1/4: winget verfuegbar? -----
Write-Host "[1/4] Pruefe winget..." -ForegroundColor Yellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  FEHLER: winget nicht gefunden." -ForegroundColor Red
    Write-Host "  -> 'App Installer' aus dem Microsoft Store installieren." -ForegroundColor Red
    exit 1
}
Write-Host "  OK: winget verfuegbar" -ForegroundColor Green
Write-Host ""

# ----- 2/4: Java JRE 17+ -----
Write-Host "[2/4] Pruefe Java..." -ForegroundColor Yellow
$javaVersion = $null
try {
    $javaOutput = & java -version 2>&1 | Select-Object -First 1
    if ($javaOutput -match 'version "(\d+)') { $javaVersion = [int]$Matches[1] }
} catch { }

if ($javaVersion -and $javaVersion -ge 17) {
    Write-Host "  OK: Java $javaVersion bereits installiert" -ForegroundColor Green
} else {
    if ($javaVersion) {
        Write-Host "  Java $javaVersion gefunden, aber 17+ benoetigt. Installiere OpenJDK 21..." -ForegroundColor Yellow
    } else {
        Write-Host "  Java nicht gefunden. Installiere OpenJDK 21..." -ForegroundColor Yellow
    }
    winget install --id Microsoft.OpenJDK.21 --silent --accept-source-agreements --accept-package-agreements
    Write-Host "  OK: Java installiert (PowerShell-Neustart fuer PATH-Update noetig!)" -ForegroundColor Green
}
Write-Host ""

# ----- 3/4: Graphviz -----
Write-Host "[3/4] Pruefe Graphviz..." -ForegroundColor Yellow
$dot = Get-Command dot -ErrorAction SilentlyContinue
$graphvizBin = "C:\Program Files\Graphviz\bin"

if (-not $dot -and (Test-Path "$graphvizBin\dot.exe")) {
    # Installiert, aber nicht im PATH -> reparieren
    Write-Host "  Graphviz vorhanden, aber nicht im PATH. Ergaenze User-PATH..." -ForegroundColor Yellow
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$graphvizBin*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$graphvizBin", "User")
        Write-Host "  OK: PATH ergaenzt um $graphvizBin (Neustart noetig!)" -ForegroundColor Green
    }
    $dot = $true
}

if ($dot) {
    Write-Host "  OK: Graphviz vorhanden" -ForegroundColor Green
} else {
    Write-Host "  Graphviz nicht gefunden. Installiere..." -ForegroundColor Yellow
    winget install --id Graphviz.Graphviz --silent --accept-source-agreements --accept-package-agreements

    if (Test-Path "$graphvizBin\dot.exe") {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$graphvizBin*") {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$graphvizBin", "User")
            Write-Host "  OK: PATH ergaenzt um $graphvizBin" -ForegroundColor Green
        }
    }
    Write-Host "  OK: Graphviz installiert (PowerShell-Neustart fuer PATH-Update noetig!)" -ForegroundColor Green
}
Write-Host ""

# ----- 4/4: plantuml.jar -----
Write-Host "[4/4] Pruefe plantuml.jar..." -ForegroundColor Yellow
if ((Test-Path $jarPath) -and -not $Force) {
    $sizeMB = [math]::Round((Get-Item $jarPath).Length / 1MB, 2)
    Write-Host "  OK: plantuml.jar bereits vorhanden ($sizeMB MB)" -ForegroundColor Green
} else {
    $jarUrl = "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
    Write-Host "  Lade plantuml.jar (latest)..." -ForegroundColor Yellow
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $jarUrl -OutFile $jarPath -UseBasicParsing
    $ProgressPreference = 'Continue'

    if (Test-Path $jarPath) {
        $sizeMB = [math]::Round((Get-Item $jarPath).Length / 1MB, 2)
        Write-Host "  OK: plantuml.jar heruntergeladen ($sizeMB MB)" -ForegroundColor Green
    } else {
        Write-Host "  FEHLER: Download fehlgeschlagen!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== Dependencies fertig ===" -ForegroundColor Cyan
Write-Host "Naechster Schritt: .\install-extensions.ps1" -ForegroundColor Yellow
Write-Host ""
exit 0
