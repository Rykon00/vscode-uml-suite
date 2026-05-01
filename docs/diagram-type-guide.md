# Diagrammtyp-Guide: Welcher Typ wann?

Das haeufigste UML-Anti-Pattern: alles in Klassendiagramme pressen,
weil das der bekannteste Typ ist. Diese Uebersicht hilft, das
richtige Werkzeug fuer die jeweilige Frage zu waehlen.

## Entscheidungs-Matrix

| Du willst zeigen...                       | Diagrammtyp        | Werkzeug             |
|-------------------------------------------|--------------------|----------------------|
| ...welche Daten/Objekte es gibt           | Klassendiagramm    | PlantUML             |
| ...wie etwas Schritt fuer Schritt ablaeuft| Sequenzdiagramm    | PlantUML / Mermaid   |
| ...welche Entscheidungen ein Prozess hat  | Aktivitaetsdiagramm| PlantUML             |
| ...die grobe Systemarchitektur            | Komponentendiagramm| PlantUML             |
| ...Architektur auf 4 Ebenen (Context...)  | C4-Modell          | C4-DSL / Structurizr |
| ...wer was im System tun darf             | Use-Case-Diagramm  | PlantUML             |
| ...welche Zustaende ein Objekt hat        | Zustandsdiagramm   | PlantUML             |
| ...physisches Deployment (Server, Netze)  | Deployment-Diagramm| PlantUML / Draw.io   |
| ...Datenmodell (DB-Schema)                | ER-Diagramm        | Mermaid              |
| ...Flows / lose Diagramme                 | Flowchart          | Mermaid              |
| ...freie Formen, kein UML-Standard noetig | -                  | Draw.io / Excalidraw |

## Detail-Empfehlungen

### Klassendiagramm
- Wann: Datenmodelle, Domain-Modelle, API-Schemata, OOP-Strukturen.
- Falle: NICHT fuer Prozessablaeufe verwenden -- dafuer ist es das falsche Werkzeug.
- Tipp: Erst die wichtigsten Klassen + Beziehungen, Methoden/Attribute spaeter.

### Sequenzdiagramm
- Wann: Detaillierte Interaktion zwischen Akteuren/Komponenten ueber Zeit.
- Falle: Bei mehr als ~10 Teilnehmern wird es unleserlich -- splitten oder vereinfachen.
- Tipp: Nicht jeden Aufruf mappen, sondern die fachlich relevanten.

### Aktivitaetsdiagramm
- Wann: Geschaeftsprozesse, Algorithmen mit Verzweigungen, Workflows.
- Falle: Nicht mit Sequenzdiagramm verwechseln -- Aktivitaet zeigt WAS,
  Sequenz zeigt WER.
- Tipp: Fuer einfache lineare Ablaeufe lieber eine nummerierte Liste.

### Komponentendiagramm
- Wann: Grobe Systemarchitektur, "Welche Bausteine reden mit welchen".
- Falle: Wird oft mit Klassendiagrammen verwechselt -- Komponenten sind
  groebere Bausteine (Services, Module), nicht einzelne Klassen.

### C4-Modell (Context, Container, Component, Code)
- Wann: Architektur-Doku fuer mittlere bis grosse Systeme, mehrere Detail-Ebenen.
- Falle: Beginne IMMER mit Level 1 (Context) -- Direkt-Einstieg auf Container-Level
  ohne Context ist verwirrend.
- Tipp: Setup-Anleitung fuer C4-DSL siehe <https://docs.structurizr.com/dsl>

### Use-Case-Diagramm
- Wann: Fruehe Anforderungsphase, "Wer darf was im System".
- Falle: Nicht fuer Implementierungsdetails -- nur fachliche Sicht.
- Tipp: Inkludiere immer alle Akteure, auch Admin/System.

### Zustandsdiagramm
- Wann: Objekte mit klar abgrenzbaren Zustaenden + Uebergaengen
  (Bestellung: offen / bezahlt / versendet / abgeschlossen).
- Falle: NICHT fuer einfache Boolean-Flags -- erst ab ~3 Zustaenden lohnenswert.

### Deployment-Diagramm
- Wann: Wo laeuft was physisch -- Server, Container, Netzwerke.
- Tipp: Bei komplexen Cloud-Setups oft besser in Draw.io oder mit
  Hersteller-Icons (AWS-, Azure-Symbole) modellieren.

## Faustregeln

1. **Im Zweifel weniger statt mehr.** Ein scharfes Diagramm ist besser als
   drei verwaschene.
2. **Keine doppelte Information.** Wenn der Code es sagt, muss das Diagramm
   es nicht auch sagen. Diagramme sind fuer das, was Code NICHT zeigen kann
   (Architektur, Beziehungen, Prozesse).
3. **Diagramme veralten schnell.** Lieber wenige, dafuer gepflegte Diagramme
   als viele veraltete.
4. **Textbasierte Diagramme (PlantUML/Mermaid) > GUI-Tools.** Sie sind
   versionierbar, diff-bar, mergebar -- echtes "Diagramme als Code".

## Zwei-Werkzeug-Empfehlung fuer Einsteiger

Wenn du nicht alle Werkzeuge gleichzeitig lernen willst, fang so an:

1. **PlantUML** fuer alle UML-Standards (Klasse, Sequenz, Aktivitaet, Komponente).
2. **Mermaid** fuer schnelle Inline-Diagramme in Markdown-Doku.

C4-DSL, Draw.io, Excalidraw kannst du dazunehmen, sobald du sie wirklich brauchst.
