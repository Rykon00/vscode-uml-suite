#Requires -Version 5.1
<#
.SYNOPSIS
  Verifiziert die UML-Diagram-Suite end-to-end.

.DESCRIPTION
  Fuehrt 7 Tests durch:
    1. Java >= 17
    2. Graphviz (dot) verfuegbar (PATH oder bekannter Standardpfad)
    3. VSCode CLI verfuegbar
    4. plantuml.jar vorhanden + lauffaehig (Output-basiert, nicht Exit-Code)
    5. Template-Files vorhanden
    6. Alle empfohlenen Extensions installiert
    7. Render-Smoke-Test (echtes Mini-Diagramm rendern)

.EXAMPLE
  .\verify-setup.ps1
#>

[CmdletBinding()]
param()

$setupDir    = $PSScriptRoot
$suiteRoot   = Split-Path $setupDir -Parent
$jarPath     = Join-Path $setupDir "plantuml.jar"
$extJsonPath = Join-Path $suiteRoot "templates\.vscode\extensions.json"

# Bekannte Standard-Pfade (Fallback, falls PATH in der aktuellen Session unvollstaendig ist)
$dotExeFallback  = "C:\Program Files\Graphviz\bin\dot.exe"
$codeCmdFallback = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd"
)

$script:passed = 0; $script:failed = 0; $script:warnings = @()

function Test-Component {
    param([string]$Name, [scriptblock]$Test)
    Write-Host "[TEST] $Name" -NoNewline -ForegroundColor Cyan
    try {
        $result = & $Test
        if ($result) {
            Write-Host " ... OK" -ForegroundColor Green
            if ($result -is [string]) { Write-Host "       $result" -ForegroundColor DarkGray }
            $script:passed++
        } else {
            Write-Host " ... FEHLER (Test hat false zurueckgegeben)" -ForegroundColor Red
            $script:failed++
        }
    } catch {
        Write-Host " ... FEHLER" -ForegroundColor Red
        Write-Host "       $_" -ForegroundColor DarkGray
        $script:failed++
    }
}

Write-Host ""
Write-Host "=== UML-Diagram-Suite: Verifikation ===" -ForegroundColor Cyan
Write-Host "Suite-Root: $suiteRoot" -ForegroundColor DarkGray
Write-Host ""

# ----- 1: Java -----
Test-Component "Java >= 17" {
    $output = & java -version 2>&1 | Select-Object -First 1
    if ($output -match 'version "(\d+)') {
        $v = [int]$Matches[1]
        if ($v -ge 17) { return "Java $v" }
        throw "Java $v installiert, aber 17+ benoetigt"
    }
    throw "Version nicht erkannt"
}

# ----- 2: Graphviz (PATH ODER bekannter Pfad) -----
# Robust: PATH-Check zuerst, sonst absoluter Pfad. Beides zaehlt als OK,
# weil PlantUML intern beide Wege findet (dotPath ist explizit in settings.json gesetzt).
Test-Component "Graphviz (dot) verfuegbar" {
    $cmd = Get-Command dot -ErrorAction SilentlyContinue
    if ($cmd) {
        $version = (& dot -V 2>&1) -join ' '
        return "PATH: $($cmd.Source) -- $version"
    }
    if (Test-Path $dotExeFallback) {
        $version = (& $dotExeFallback -V 2>&1) -join ' '
        $script:warnings += "Graphviz nicht im aktuellen PATH (nur in der laufenden Session). Neue Sessions sehen es."
        return "Fallback: $dotExeFallback -- $version"
    }
    throw "dot.exe nicht gefunden (weder PATH noch $dotExeFallback)"
}

# ----- 3: VSCode CLI -----
Test-Component "VSCode CLI verfuegbar" {
    $found = $codeCmdFallback | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $found) { throw "code.cmd nicht gefunden" }
    $version = & $found --version | Select-Object -First 1
    return "VSCode $version"
}

# ----- 4: plantuml.jar (Output-basiert, nicht Exit-Code-basiert) -----
# PlantUML kann mit -version einen non-zero Exit-Code liefern, obwohl der Aufruf
# erfolgreich war. Daher pruefen wir den Output auf das Versions-Pattern.
Test-Component "plantuml.jar vorhanden + lauffaehig" {
    if (-not (Test-Path $jarPath)) { throw "Datei fehlt: $jarPath" }
    $output = (& java -jar $jarPath -version 2>&1) -join "`n"
    if ($output -match 'PlantUML version[^\r\n]*') {
        return $Matches[0].Trim()
    }
    throw "Jar laeuft, aber Output enthaelt keine 'PlantUML version'-Zeile. Output war: $output"
}

# ----- 5: Template-Files -----
Test-Component "Template-Files vorhanden" {
    $expected = @(
        "templates\.vscode\settings.json",
        "templates\.vscode\extensions.json",
        "templates\.vscode\snippets\plantuml.code-snippets",
        "templates\starter-uml\01-class-example.puml",
        "templates\starter-uml\02-sequence-example.puml",
        "templates\starter-uml\03-component-example.puml",
        "templates\starter-uml\04-activity-example.puml",
        "templates\starter-md\README-with-diagrams.md",
        "templates\starter-md\architecture-decision-record.md"
    )
    $missing = $expected | Where-Object { -not (Test-Path (Join-Path $suiteRoot $_)) }
    if ($missing.Count -gt 0) { throw "Fehlende Files: $($missing -join ', ')" }
    return "$($expected.Count) Template-Files vorhanden"
}

# ----- 6: Extensions -----
Test-Component "Alle empfohlenen Extensions installiert" {
    $codeCmd = $codeCmdFallback | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $codeCmd) { throw "VSCode CLI nicht gefunden" }
    $expected  = (Get-Content $extJsonPath -Raw | ConvertFrom-Json).recommendations
    $installed = & $codeCmd --list-extensions
    $missing   = $expected | Where-Object { $_ -notin $installed }
    if ($missing.Count -gt 0) { throw "Fehlende: $($missing -join ', ')" }
    return "$($expected.Count) von $($expected.Count) Extensions installiert"
}

# ----- 7: Render-Smoke-Test (End-to-end Beweis) -----
Test-Component "Render-Smoke-Test (PlantUML -> SVG)" {
    $tmpDir = Join-Path $env:TEMP "uml-suite-verify"
    if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    $tmpPuml = Join-Path $tmpDir "smoketest.puml"
    @(
        "@startuml",
        "Alice -> Bob : verify",
        "Bob --> Alice : OK",
        "@enduml"
    ) | Set-Content -Path $tmpPuml -Encoding UTF8

    & java -jar $jarPath -tsvg $tmpPuml 2>&1 | Out-Null
    $tmpSvg = Join-Path $tmpDir "smoketest.svg"
    if (-not (Test-Path $tmpSvg)) { throw "SVG nicht erzeugt" }

    $size = (Get-Item $tmpSvg).Length
    Remove-Item $tmpDir -Recurse -Force
    return "SVG erfolgreich gerendert ($size Bytes)"
}

# ----- Zusammenfassung -----
Write-Host ""
Write-Host "=== Zusammenfassung ===" -ForegroundColor Cyan
Write-Host "  Bestanden: $script:passed" -ForegroundColor Green
$failColor = if ($script:failed) { 'Red' } else { 'DarkGray' }
Write-Host "  Fehler:    $script:failed" -ForegroundColor $failColor

if ($script:warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Hinweise:" -ForegroundColor Yellow
    $script:warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
Write-Host ""

if ($script:failed -eq 0) {
    Write-Host "Suite ist vollstaendig und funktional." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Suite hat Probleme. Fix die FEHLER und nochmal verifizieren." -ForegroundColor Red
    exit 1
}
