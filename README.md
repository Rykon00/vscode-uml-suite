# VSCode UML-Diagram Suite

Reproduzierbares VSCode-Setup fuer UML-Diagramme: PlantUML, Mermaid, C4-DSL, Draw.io
plus passende Settings, Snippets und Templates.

## Quick Start

```powershell
git clone <REPO-URL>
cd vscode-uml-suite\setup
.\install-deps.ps1          # Java + Graphviz + plantuml.jar
.\install-extensions.ps1    # VSCode-Extensions  (PowerShell vorher neu starten!)
.\verify-setup.ps1          # 7 End-to-End-Tests
```

## Struktur

- setup/      -- Installations- und Verifikations-Skripte
- templates/  -- .vscode-Konfig und Beispiel-Diagramme zum Reinkopieren
- docs/       -- Workflow, Cheatsheet, Diagrammtyp-Guide
- profile/    -- exportiertes VSCode Profile (Ein-Klick-Import)

## Doku

- docs/workflow.md
- docs/plantuml-cheatsheet.md
- docs/diagram-type-guide.md
- setup/install-deps.md

## Lizenz

MIT (siehe LICENSE)
