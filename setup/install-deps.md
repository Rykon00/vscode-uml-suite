# Setup-Anleitung: UML-Diagram-Suite

Diese Suite braucht drei System-Komponenten plus die VSCode-Extensions.
Auf einem neuen Rechner reichen drei Befehle, um alles wiederherzustellen.

## Komponenten

| Komponente      | Wofuer                                                       | Quelle                  |
|-----------------|--------------------------------------------------------------|-------------------------|
| **Java JRE 17+**| PlantUML laeuft auf der JVM; C4-DSL-Language-Server auch     | Microsoft OpenJDK 21    |
| **Graphviz**    | Layout-Engine fuer Klassen-/Komponentendiagramme (`dot`)     | graphviz.org            |
| **plantuml.jar**| PlantUML-Renderer fuer Markdown Preview Enhanced             | github.com/plantuml     |
| **VSCode Extensions** | Editor-Integration (PlantUML, Mermaid, C4, Draw.io, ...) | VSCode Marketplace  |

## Reihenfolge auf neuem Rechner

```powershell
# Im Suite-Root, also dort wo dieser Ordner "setup\" liegt:
cd <pfad>\.UML-Diagram_Suite\setup

# 1. System-Dependencies (Java, Graphviz, plantuml.jar)
.\install-deps.ps1

# === HIER PowerShell schliessen + neu oeffnen ===
# (sonst kennt die Session den neuen PATH von Java/Graphviz nicht)

cd <pfad>\.UML-Diagram_Suite\setup

# 2. VSCode-Extensions
.\install-extensions.ps1

# 3. Verifikation
.\verify-setup.ps1
```

`verify-setup.ps1` muss am Ende mit *"Suite ist vollstaendig und funktional"* enden.
Falls nicht: die FEHLER-Zeilen lesen, das jeweilige Problem fixen, nochmal verifizieren.

## Skript-Eigenschaften

Alle drei Skripte sind:

- **idempotent** -- mehrfach ausfuehren ist sicher, bestehendes wird nicht zerstoert
- **selbstauffindend** -- finden ihre Pfade ueber `$PSScriptRoot`, kein Hardcoding
- **mit Exit-Codes** -- 0 = OK, 1 = Fehler (fuer spaetere Automatisierung)
- **mit `-Force`-Schalter** (deps + extensions) -- erzwingt Re-Installation

## Manuelle Installation (falls winget nicht verfuegbar)

- **Java JRE 21**: <https://learn.microsoft.com/en-us/java/openjdk/download>
- **Graphviz**:    <https://graphviz.org/download/>  (Windows Installer)
- **plantuml.jar**: <https://github.com/plantuml/plantuml/releases/latest> -> `plantuml.jar` ins `setup/`-Verzeichnis legen

Nach manueller Installation: PATH-Variable pruefen
(Graphviz braucht `C:\Program Files\Graphviz\bin` im PATH).

## Troubleshooting

| Symptom                                    | Ursache / Loesung                                         |
|--------------------------------------------|-----------------------------------------------------------|
| `dot: command not found` nach winget       | PowerShell schliessen + neu oeffnen                       |
| `Error: plantuml.jar file not found: ""`   | `install-deps.ps1` nicht ausgefuehrt -- jar fehlt im setup/ |
| Extension-Install: `not found`             | Falsche Extension-ID -- pruefe `extensions.json`           |
| MPE rendert PlantUML nicht                 | `plantumlJarPath` in `.vscode/settings.json` zeigt ins Leere |
