# Case Study: Drei-Schichten-Privacy-Modellierung

> Architektur-Pattern für persönliche Modellierungs­projekte in sensiblen Settings,
> bei denen drei unterschiedliche Daten-Sensibilitätsstufen sauber getrennt werden müssen.

**Erstellt:** 2026-05-01
**Status:** Erprobtes Architektur-Pattern, in produktivem Einsatz
**Scope:** Datenmodell, Repo-Struktur, Datenschutz-Strategie, technische Werkzeuge
**Referenz-Setup:** Diese UML-Diagram-Suite

---

## 1. Zusammenfassung

Dieses Pattern beschreibt, wie man ein persönliches Modellierungs-Projekt in einem sensiblen Setting datenschutz-konform aufbaut, wenn drei sehr unterschiedliche Sichten zusammenkommen sollen: räumliche Karte (A), funktionales/soziales System (B) und persönliches Reflexionswerkzeug (C).

Sensible Settings im Sinne dieses Patterns sind alle Kontexte, in denen identifizierbare Daten anderer Personen oder geschützter Organisationen anfallen können — Pflege­einrichtungen, Bildungs­einrichtungen, geschlossene Communities, Firmengelände mit NDA-Bezug, religiöse Einrichtungen, Vereine mit besonderen Mitgliederrechten und vergleichbare Konstellationen.

Die zentrale Herausforderung ist nicht technischer, sondern **datenschutz-rechtlicher** Natur. Der Lösungsansatz:

- **Drei-Schichten-Datenmodell** mit klarer Trennung nach Sensibilität
- **Hybrid-Storage**: privates Git-Repo + externer verschlüsselter Speicher für sensibelste Daten
- **Pseudonymisierungs-Tabelle ab Tag 1** als zentrales Anker-Konzept
- **git-crypt** für Verschlüsselung der mittleren Sensibilitäts-Schicht im Repo
- **Single-User by Design** — bewusst keine Multi-User-Architektur
- **UML 2.5 mit OCL-Constraints** für formal saubere Strukturmodellierung
- **Zeit-dimensionale Tagebuch-Aggregation** (täglich → wöchentlich → monatlich)

Aufwand-Einschätzung: ca. 3–4h für das Initial-Setup (inkl. git-crypt + Ontologie-Modellierung), danach inkrementell.

---

## 2. Risiko-Analyse

### 2.1 Was DSGVO-rechtlich relevant ist

Auch persönliche Notizen über andere Menschen sind nach DSGVO eine Datenverarbeitung. Zwei Punkte besonders beachten:

- **Datenerhebung selbst ist bereits Verarbeitung** — nicht erst die Veröffentlichung. Das Aufschreiben einer Beobachtung über eine andere Person ist juristisch derselbe Vorgang wie eine professionelle Aktennotiz, nur ohne Rechtsgrundlage.
- **Re-Identifikation ist erstaunlich leicht.** Schon drei Datenpunkte reichen statistisch aus, um die meisten Menschen eindeutig zu identifizieren — selbst wenn der Name fehlt. "Junge Person, Raum 4, kommt aus Stadt X" ist faktisch ein Personenidentifikator.

### 2.2 Risikoebenen im Projekt

| Inhaltstyp                                            | Risiko      | Strategie                          |
|-------------------------------------------------------|-------------|------------------------------------|
| Eigene Räume, Wege, Türen, Gebäude                    | sehr gering | Anonymisiert, privates Repo        |
| Eigenes Erleben, Gedanken, Stimmungen                 | gering      | Privates Repo, kein Cloud-Sync     |
| Eigene Verfassung / persönlicher Status               | mittel      | Privates Repo, verschlüsselt       |
| Räume ohne erkennbare Identität der Einrichtung       | gering      | Privates Repo möglich              |
| Räume mit identifizierbarer Beschilderung etc.        | mittel      | Privates Repo, neutrale Namen      |
| Andere Personen im Setting — auch ohne Klarnamen      | **hoch**    | Niemals committen, externer Vault  |
| Mitarbeiter / Verantwortliche der Einrichtung         | **hoch**    | Niemals committen, externer Vault  |
| Interne Abläufe, nicht-öffentliche Prozesse           | hoch        | Niemals committen, externer Vault  |
| Identifikation der Einrichtung im Repo-Namen          | mittel      | Repo-Name neutralisieren           |

### 2.3 Daraus folgende Grundregeln

1. **Repo-Name enthält keinen Bezug zur konkreten Einrichtung.** Generische Bezeichnungen wie `place-cartography`, `gelaende-mapping` oder `local-modeling` sind sicherer als spezifische Namen.
2. **Drei Schichten** sind getrennte Verzeichnisse mit getrennten Storage-Strategien.
3. **`.gitignore` ist die wichtigste Datei des Projekts.** Sie wird zuerst angelegt und sehr restriktiv gehalten.
4. **Pseudonymisierung als Default**, falls überhaupt Personen in Notizen vorkommen — auch im externen Vault.
5. **Identifizierende Merkmale der Einrichtung neutralisieren**: keine Bereichsnamen, Telefonnummern, Schichtpläne, Personallisten — auch nicht im verschlüsselten Privat-Bereich, weil das Nichtvorhandensein einer Information immer einen besseren Schutz darstellt als ihre Verschlüsselung.

---

## 3. Drei-Schichten-Datenmodell

Die Antwort auf "A + B + C in einer Suite" ist: **ja, in einer Suite — aber als drei unabhängige Schichten mit unterschiedlichem Datenschutz-Niveau.**

### Schicht 1: Strukturmodell (anonymisiert)

**Was:** Räumliche und funktionale Modellierung des Geländes ohne Personenbezug.

- Lageplan, Gebäude, Verbindungswege, Türen, Treppen
- Funktionale Zonen (Aufenthalt, Arbeit, Außenbereich) — abstrakt, nicht einrichtungs-spezifisch
- Beziehungen zwischen Räumen
- UML-Modelle: Was ist ein Gebäude, ein Raum, eine Zone, ein Weg? Welche Eigenschaften, welche Beziehungen?

**Ziel-Output:** SVG-Lageplan + UML-Klassendiagramme + Komponentendiagramme.

**Schutz-Niveau:** Privates Repo. Eine vollständig anonymisierte Version wäre theoretisch sogar für eine Public-Version geeignet, weil das Strukturmodell auch ohne Einrichtungs-Bezug konzeptionell interessant ist. In der Praxis bleibt es **privat**, weil eine versehentliche Identifikation über Geometrie-Vergleiche mit Luftbildern möglich ist.

### Schicht 2: Persönliches Erleben (privat, verschlüsselt)

**Was:** Eigene Eindrücke, Tagesnotizen, Reflexionen — ausschließlich über sich selbst.

- "An Tag X war ich an Ort Y und es fühlte sich Z an."
- Tagebuch zur eigenen Verfassung
- Eigene Beobachtungen über die eigene Wahrnehmung

**Ziel-Output:** Markdown-Journal, optional verlinkt mit Schicht 1 (z.B. Verweis auf den Knoten `building-A/room-12` im Strukturmodell).

**Schutz-Niveau:** Privates Repo, **zusätzlich** mit `git-crypt` verschlüsselt. Datei-Endung `*.enc.md` für Auto-Encryption.

### Schicht 3: Externe Beobachtungen (externer Vault, niemals Repo)

**Was:** Alles, was andere Personen oder identifizierbare interne Daten der Einrichtung enthalten könnte.

- Notizen über Begegnungen mit anderen Personen im Setting
- Inhalte aus geschützten Kontexten
- Einrichtungs-spezifische Abläufe, Pläne, Strukturen, die nicht öffentlich sind

**Ziel-Output:** Verschlüsselter externer Vault (z.B. OneDrive Personal Vault, Cryptomator-Container, verschlüsseltes Boxcryptor-Volume), **nicht im Git-Repo**, Datei-Format frei wählbar.

**Schutz-Niveau:** Externer Vault mit Endgerät-Verschlüsselung (BitLocker o.ä. vorausgesetzt), strikt separater Pfad außerhalb jedes Git-Verzeichnisses, keine direkte Verlinkung zwischen Schicht 3 und Schicht 1/2.

### 3.1 Zentrales Konzept: Die Pseudonymisierungs-Tabelle

Die "Pseudonymisierung als Default" aus Abschnitt 2.3 funktioniert nur, wenn sie **ab Tag 1** durchgehalten wird. Sie nachträglich beim Verlassen des Settings anzuwenden ist nicht praktikabel, denn um Wochen später Notizen wiederzufinden und einzupflegen, braucht es Wiedererkennungs-Anker — und genau diese Anker sind das Identifizierende, das wir vermeiden wollen.

**Lösung:** Eine zentrale Pseudonymisierungs-Tabelle als Single Source of Truth in Schicht 3.

- **Speicherort:** Im externen Vault, z.B. `<Vault>/<projekt>/pseudonyms.md`
- **Inhalt:** Zwei-Spalten-Mapping. Links: minimal beschreibendes Merkmal. Rechts: stabile ID (`PEER-03`).
- **Lebenszyklus:** Sobald einer Person zum ersten Mal eine ID zugewiesen wird, gilt diese dauerhaft. Auch wenn die Person Wochen später wieder erscheint, sucht man in der Tabelle nach dem Merkmal und nutzt die bestehende ID. Konsistenz ist wichtiger als Eleganz.
- **In Schicht 2/3:** Es erscheinen **ausschließlich die IDs**. `STAFF-07`, `PEER-03`. Niemals beschreibende Merkmale.

**Empfohlenes ID-Schema (an Setting anpassen):**

| Präfix       | Bedeutung (am Beispiel)                  | Beispiel          |
|--------------|------------------------------------------|-------------------|
| `PEER-NN`    | Andere Personen im selben Status         | `PEER-03`         |
| `STAFF-NN`   | Operatives Personal                      | `STAFF-07`        |
| `LEAD-NN`    | Leitungsfunktionen                       | `LEAD-01`         |
| `EXPERT-NN`  | Fachpersonal mit besonderer Rolle        | `EXPERT-02`       |
| `VISITOR-NN` | Besucher (eigene oder fremde)            | `VISITOR-01`      |
| `EXTERNAL-NN`| Externe Dienstleister, Handwerker, etc.  | `EXTERNAL-04`     |

Falls die Tabelle verloren geht, ist das kein Datenschutz-Vorfall — es macht nur die eigenen Notizen weniger nachverfolgbar. Das ist ein gewünschter Trade-off: die Tabelle ist die **persönliche Brille**, ohne die niemand etwas mit den Pseudonymen anfangen kann.

**Wichtig:** Die Tabelle wird niemals in irgendeiner Form mit Schicht 1 oder 2 vermischt. Auch nicht "nur kurz reinkopiert zum Suchen". Wenn du sie brauchst, öffnest du sie aus dem Personal Vault, schaust nach, schließt sie wieder.

### Architektur-Diagramm

```
┌─────────────────────────────────────────────────────────────┐
│              Drei-Schichten-Privacy-Modellierung             │
└─────────────────────────────────────────────────────────────┘

   ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
   │   Schicht 1    │  │   Schicht 2    │  │   Schicht 3    │
   │  Strukturmodell│  │  Eigenes Erleben│  │  Externe Daten │
   │                │  │                │  │                │
   │  - Gebäude     │  │  - Tagebuch    │  │  - andere      │
   │  - Räume       │  │  - Reflexionen │  │    Personen    │
   │  - Wege        │  │  - eigene      │  │  - Personal    │
   │  - Funktionen  │  │    Verfassung  │  │  - Abläufe     │
   │                │  │                │  │  - geschützte  │
   │                │  │  *.enc.md      │  │    Inhalte     │
   │   .puml/.md    │  │  (git-crypt)   │  │  - Pseudonym-  │
   │   (privat)     │  │  nutzt nur IDs │  │    Tabelle     │
   └────────┬───────┘  └────────┬───────┘  └────────┬───────┘
            │                   │                    │
            ▼                   ▼                    ▼
   ┌────────────────────────────────┐  ┌────────────────────┐
   │   Privates GitHub-Repo          │  │  Externer Vault    │
   │   (neutraler Name)              │  │  (z.B. OneDrive    │
   │                                  │  │  Personal Vault)   │
   │   Encryption via git-crypt       │  │                    │
   │   für Schicht 2                  │  │  Single Source of  │
   │                                  │  │  Truth für         │
   │                                  │  │  Pseudonyme        │
   └──────────────────────────────────┘  └────────────────────┘

                       Datenfluss-Regel:
                  Schicht 3 ──> niemals nach 1/2
                  Schicht 1 <─> Schicht 2 OK
                  IDs aus Schicht 3 duerfen in Schicht 2 vorkommen,
                  aber niemals die Pseudonym-Aufloesungen.
```

---

## 4. Repo-Struktur (Schicht 1 + 2)

```
<projekt-name>/                    # generischer, neutraler Name
├── .gitignore                     # ZUERST anlegen, restriktiv
├── .gitattributes                 # git-crypt Filter-Regeln
├── .git-crypt/                    # Auto-erstellt, NICHT manuell anfassen
├── README.md                      # nur Strukturbeschreibung, keine Setting-Identifikation
│
├── .vscode/                       # aus UML-Suite Templates
│   ├── settings.json
│   ├── extensions.json
│   └── snippets/
│
├── 01-strukturmodell/             # SCHICHT 1 — UML 2.5 mit OCL
│   ├── README.md                  # Modellierungs-Konzept
│   ├── ontology/
│   │   ├── 01-domain-model.puml   # Was ist ein Gebäude, Raum, Weg?
│   │   ├── 02-relationships.puml  # Wie hängen Konzepte zusammen?
│   │   ├── 03-zones.puml          # Funktionale Zonen
│   │   └── 04-ocl-constraints.md  # Invarianten in OCL-Notation
│   ├── geometry/
│   │   ├── overview.puml          # High-Level-Layout
│   │   ├── building-A.puml        # Pro Gebäude ein File (anonyme IDs)
│   │   └── ...
│   ├── paths/
│   │   ├── walking-paths.puml     # Verbindungen
│   │   └── access-graph.puml      # Erreichbarkeitsgraph
│   └── map/
│       └── lageplan.svg           # Finale Karte (Hand-erstellt oder Inkscape)
│
├── 02-erleben/                    # SCHICHT 2 — alles git-crypt-verschlüsselt
│   ├── README.enc.md              # Verschlüsselt, weil bereits Inhalt sensibel
│   ├── daily/                     # tägliche Einträge
│   │   ├── 2026-05-01.enc.md
│   │   ├── 2026-05-02.enc.md
│   │   └── ...
│   ├── weekly/                    # automatisch aggregierte Wochenberichte
│   │   ├── 2026-W18.enc.md
│   │   └── ...
│   ├── monthly/                   # automatisch aggregierte Monatsberichte
│   │   ├── 2026-05.enc.md
│   │   └── ...
│   ├── yearly/                    # für später (Jahresreflexionen)
│   │   └── .gitkeep
│   ├── reflections/               # themen­basierte Längsschnitte
│   │   └── themes.enc.md
│   └── tools/                     # Aggregations-Skripte
│       ├── aggregate-week.ps1
│       ├── aggregate-month.ps1
│       └── aggregate-year.ps1
│
└── docs/
    ├── methodology.md             # Wie modelliere ich? Was ist ein "Knoten"?
    ├── data-classification.md     # Welche Schicht enthält was? Privacy-Regeln.
    └── ocl-cheatsheet.md          # OCL-Syntax-Referenz für Schicht 1
```

**Was NICHT im Repo ist:**
- Schicht 3 (komplett externer Vault, inkl. Pseudonymisierungs-Tabelle)
- Fotos, Skizzen, Audio (auch nicht verschlüsselt — zu groß, zu identifikationsanfällig)
- Klar­namen jeglicher Art (auch nicht in Schicht 2 — dort nur Pseudonym-IDs)
- Konkrete Bezeichnungen identifizierbarer Bereiche oder Einrichtungs-Identifikatoren

### 4.1 Zeit-Dimensionen in Schicht 2

Die Tagebuch-Architektur nutzt vier Zeit-Granularitäten, die mit Aggregations-Skripten verknüpft sind:

| Granularität | Eingabe                  | Ausgabe                       | Manuell oder generiert |
|--------------|--------------------------|-------------------------------|------------------------|
| **daily**    | manuell verfasst         | `YYYY-MM-DD.enc.md`           | manuell                |
| **weekly**   | alle daily-Files der Woche | `YYYY-Www.enc.md`           | per Skript             |
| **monthly**  | alle weekly-Files des Monats | `YYYY-MM.enc.md`          | per Skript             |
| **yearly**   | alle monthly-Files des Jahres | `YYYY.enc.md`            | per Skript (Zukunft)   |

**Aggregations-Logik:** Die Skripte sind nicht trivial "alle Files konkatenieren". Sie analysieren strukturierte Frontmatter-Felder in den daily-Files (Stimmung, Energie-Level, dominante Themen, besuchte Strukturmodell-Knoten, eingesetzte Pseudonym-IDs) und generieren daraus einen verdichteten Bericht.

**Beispiel-Frontmatter eines daily-Files:**

```yaml
---
date: 2026-05-01
mood: 6/10
energy: 4/10
themes: [reflexion, gespraech, unruhe]
locations: [building-A/room-12, outdoor-zone/garden]
encounters: [PEER-03, STAFF-07]
weather: bewoelkt, mild
---
```

Aus dieser Struktur kann das Wochen-Aggregations-Skript ableiten: "diese Woche dominante Themen: X, Y. Häufigste Aufenthaltsorte: A, B. Stimmungs-Trendlinie: leicht positiv. Wiederkehrende Encounters: STAFF-07 (5x), PEER-03 (3x)." Solche Auswertungen sind über Wochen/Monate hinweg sehr aufschlussreich, ohne dass jemals identifizierende Information eingeflossen wäre.

### 4.2 OCL-Constraints für Schicht 1

UML-Klassendiagramme sagen "ein Gebäude hat Räume". OCL macht daraus präzise Invarianten:

```ocl
context Building
inv: self.rooms->forAll(r | r.belongsTo = self)
inv: self.rooms->size() >= 1
inv: self.rooms->collect(name)->isUnique(name)

context Path
inv: self.connects->size() >= 2
inv: self.connects->forAll(p1, p2 | p1 <> p2 implies true)
   -- ein Weg verbindet mindestens zwei verschiedene Orte

context Room
inv: self.neighbors->excludes(self)
   -- kein Raum ist sein eigener Nachbar

context Zone
inv: self.contains->forAll(loc | loc.zone = self)
   -- transitive Konsistenz: Zone-Inhalt muss zur Zone gehören
```

**Pragmatische Nutzung statt formaler Verifikation:** Die OCL-Constraints sind dokumentierte Modell-Annahmen. Wir validieren sie nicht automatisch (das wäre Eclipse OCL-Tooling und Setup-Aufwand), sondern als Selbstdisziplin: jedes Geometrie-Diagramm muss die OCL-Regeln einhalten, sonst ist es inkonsistent.

Der Aufwand-Nutzen-Trade-off: ohne OCL hat man "schöne UML-Bilder", mit OCL hat man ein **wirkliches formales Modell**, das im Zweifelsfall an Hochschulen oder bei späteren Projekten als ernstzunehmender Modellierungsansatz durchgeht. Bei deinem Anspruch auf UML-Konformität ist OCL die natürliche Konsequenz.

---

## 5. Werkzeug-Empfehlungen

### 5.1 git-crypt für Schicht 2

**Begründung:** git-crypt ist seit 2025-09 in Version 0.8.0 stabil. Verschlüsselt transparent beim Push, entschlüsselt beim Checkout — man arbeitet mit den Files, als wären sie unverschlüsselt. AES-256 in CTR-Modus mit synthetischem IV aus SHA-1-HMAC. Beweisbar semantisch sicher unter deterministischem Chosen-Plaintext-Angriff, leakt also keine Information außer "sind zwei Files identisch".

**Wichtige Limitierungen, die akzeptiert werden:**

- git-crypt verschlüsselt **keine Dateinamen, Commit-Messages, Symlink-Ziele oder andere Metadaten**. Dateinamen müssen also ebenfalls neutral gewählt werden (`2026-05-01.enc.md` statt `gespraech-mit-X.enc.md`).
- Verschlüsselte Files sind nicht komprimierbar. Jeder Edit speichert das ganze File neu, nicht nur das Delta. Bei Markdown-Tagebuch unkritisch, bei Bildern wäre es ein Problem.
- Kein Schlüssel-Rotation und kein Entzug von GPG-Usern. Bei einem Single-User-Projekt egal, im Team wäre es ein Problem.

**Alternative**, falls git-crypt-Setup zu aufwendig wird: Schicht 2 komplett in `.gitignore` setzen und auch in den externen Vault auslagern — dann gibt es nur Schicht 1 im Repo. Weniger elegant, aber unangreifbar.

### 5.2 Externer Vault für Schicht 3

**Optionen je nach Plattform:**

- **OneDrive Personal Vault** (Windows): BitLocker auf Endgerät + Microsoft-seitig at-rest, Auto-Lock nach Inaktivität, 2FA für Zugriff.
- **Cryptomator** (Cross-Platform): Open-Source, transparent verschlüsselter Container, beliebige Cloud-Storage-Backends.
- **Verschlüsseltes Volume** (VeraCrypt o.ä.): Klassischer Container-Ansatz, sehr hohe Sicherheit, dafür weniger komfortabel im Alltag.

**Strikte Regel:** Der Vault-Pfad ist **nirgendwo** im Git-Repo referenziert — keine relativen Pfade, keine Hard-Links, keine Kommentare. Schicht 1 und 3 sind logisch komplett getrennt.

### 5.3 PlantUML-Modellierungswerkzeuge

Schon vorhanden in dieser UML-Suite. Für das Strukturmodell konkret nutzbar:

- **Klassendiagramme** für die Ontologie (Was ist ein Gebäude, Raum, Weg?)
- **Komponentendiagramme** für funktionale Zonen
- **Aktivitätsdiagramme** für typische Wege/Routinen (anonymisiert)
- **Mindmaps/Wardley** (PlantUML kann das auch) für Erleben-Themen in Schicht 2

### 5.4 Lageplan-Erstellung

Drei Optionen, in zunehmender Komplexität:

1. **PlantUML deployment-Diagramme** für eine schematische Karte. Schnell, textbasiert, gut versionierbar, aber nicht maßstäblich.
2. **Inkscape oder draw.io** für eine handgezeichnete SVG-Karte mit echten Proportionen. Mehr Aufwand, dafür echtes "Karten-Gefühl".
3. **GeoJSON + Leaflet** für eine wirkliche geographische Karte. Maximale Genauigkeit, aber für ein einzelnes Gelände meist Overkill.

**Empfehlung:** Mit Option 1 starten (sofort beginnbar, voll im Git versionierbar), bei Bedarf später auf Option 2 wechseln. Option 3 nur wenn am Ende wirklich eine geographisch korrekte Karte gebraucht wird.

---

## 6. Privacy-by-Design-Praktiken im Alltag

### 6.1 Beim Modellieren

- **Anonyme IDs statt Namen:** `building-A`, `building-B`, `room-12`, nicht "Haus 4 Bereich 2".
- **Funktionsbezeichnungen statt Eigennamen:** `work-zone`, `outdoor-zone`, nicht der echte Bereichsname.
- **Keine Personenkennzeichnungen**, auch nicht abstrakte: kein "eine Person", kein "ein Mitarbeiter" in Schicht 1. Schicht 1 ist menschenleer per Definition.

### 6.2 Beim Tagebuch (Schicht 2)

- **Pseudonymisierung im Eigenkontext:** wenn über andere geschrieben wird (was eigentlich Schicht 3 wäre), tu es trotzdem nur mit Pseudonymen. Falls jemals ein Schicht-3-Inhalt aus Versehen in Schicht 2 landet, soll der Schaden minimiert sein.
- **Keine direkten Zitate** von anderen Personen. Paraphrasieren oder weglassen.
- **Vorsicht mit Zeit-Kontext:** "letzten Donnerstag um 14 Uhr im Garten" + Strukturmodell ist eine Re-Identifikation. Lieber zeitlich vager bleiben.

### 6.3 Beim Committen

- **Commit-Messages neutral formulieren.** "Add building-B geometry" ist okay, "Add bereich 4a layout" nicht.
- **Vor jedem Commit `git status` prüfen.** Entwicklung einer Routine: schauen, was tatsächlich gestaged ist, bevor `git commit` läuft.
- **Pre-Commit-Hook erwägen**, der Pattern-Matching auf bekannte sensible Begriffe macht. Optional, aber wirksam als Sicherheitsnetz.

### 6.4 Beim Teilen (auch wenn aktuell privat geplant)

- Wenn das Projekt jemals geteilt werden soll, **nicht das ganze Repo** teilen, sondern eine **Public-Fork-Variante** anlegen, in der Schicht 2 komplett fehlt und Schicht 1 zusätzlich von letzten Setting-Spuren bereinigt ist.
- "Privates Repo auf GitHub" ist nicht "sicher". GitHub-Mitarbeiter, Subpoenas, Sicherheitslücken — Privatheit ist relativ.

---

## 7. Modellierungs-Methodik

Damit man nicht nach drei Wochen mit zerfallenden Modellen dasteht, lohnt es sich, die Methodik vorab zu klären. Vorschlag in vier Iterationen:

### Iteration 1: Ontologie (1–2h)

Bevor irgendwas gezeichnet wird, schreibt man Klassendiagramme für **die Begriffe**:

- Was ist ein **Ort**? (Oberklasse)
- Davon abgeleitet: **Gebäude**, **Raum**, **Außenbereich**, **Übergang** (Tür, Treppe, Gang).
- Was ist eine **Zone**? Wie unterscheidet sie sich von einem Ort?
- Was ist ein **Weg**? Verbindet er Orte oder Zonen?
- Welche Eigenschaften hat jeder dieser Typen?

**Methodik-Frage:** "Hat ein Gebäude Räume oder ist ein Gebäude eine Sammlung von Räumen?" Das ist Komposition vs. Aggregation. Richtige Modellierung dieser Begriffe macht den Unterschied zwischen "schickem Diagramm" und "tatsächlich nützlichem Modell".

### Iteration 2: Top-Level-Lageplan (2–3h)

Erst grob, dann fein. Erste Version: 5–10 Knoten, die ganz grobe Bereiche darstellen. Verbindungen zwischen ihnen. Keine Detailgenauigkeit. Ziel: das **mentale Modell** auf eine Seite bringen.

### Iteration 3: Vertiefung pro Bereich (inkrementell, ongoing)

Pro Bereich, den man tatsächlich erlebt, ein eigenes Detail-Diagramm. Nicht versuchen, das ganze Gelände gleichzeitig zu modellieren — meist kennt man es nicht ganz. Inkrementell wachsen lassen.

### Iteration 4: Schicht-2-Verlinkung (ongoing parallel)

Während Schicht 1 wächst, schreibt man parallel Schicht 2 als Tagebuch. Verweise im Tagebuch auf Knoten in Schicht 1 (`siehe building-A/room-12 in geometry/`). So entsteht über Zeit ein begehbares, persönliches Mental Model des Geländes.

---

## 8. Konkrete erste Schritte

Beim Aufsetzen eines neuen Projekts in dieser Reihenfolge vorgehen:

1. **Repo-Name festlegen.** Generischer, neutraler Name. Wichtig: keine Identifikation des Settings im Namen.
2. **Repo lokal anlegen** mit der UML-Suite-Struktur als Vorlage (`.vscode/` aus den Templates kopieren).
3. **Privacy-Files zuerst:** `.gitignore`, `.gitattributes`, `data-classification.md`. Das ist der Grundstein, alles andere baut darauf auf.
4. **git-crypt einrichten** für Schicht 2 (alternativ: Schicht 2 komplett in den externen Vault auslagern, simpler aber zwei Storage-Orte).
5. **Pseudonymisierungs-Tabelle initialisieren** im externen Vault, mit dem ID-Schema aus Abschnitt 3.1.
6. **Ontologie-Diagramm bauen** als erstes Modellierungs-File. Das zwingt dazu, sich die Begriffe klar zu machen, bevor Geometrie modelliert wird.
7. **Top-Level-Lageplan** mit 5–10 Knoten, erst dann Detaillierung.
8. **Tagebuch-Routine** etablieren — täglicher kurzer Eintrag, auch wenn nur ein Satz.

Der gesamte Setup-Aufwand bis "produktiv arbeitsfähig" liegt bei realistisch 3–4 Stunden.

---

## 9. Getroffene Entscheidungen

Die ursprünglich offenen Architektur-Fragen sind beantwortet:

### 9.1 Verschlüsselung in Schicht 2 → git-crypt

**Entscheidung:** Schicht 2 wird mit `git-crypt` direkt im Repo verschlüsselt.

**Begründung:** Ein Storage-Ort statt zwei. Eleganter Workflow, transparentes Encryption beim Push, transparente Entschlüsselung beim Checkout. Der Setup-Aufwand ist einmalig.

### 9.2 Multi-User-Funktionalität → bewusst ausgeschlossen

**Entscheidung:** Single-User by Design. Keine Architektur-Vorbereitung für andere Personen.

**Begründung:** In sensiblen Settings ist das Aufnehmen weiterer Komplexitätsebenen — auch nur architektonisch — kontraproduktiv. Die Idee, andere Personen im selben Setting beim Modellieren oder Tagebuchführen zu unterstützen, ist aus Engineering-Sicht spannend, aber aus persönlicher Sicht eine zusätzliche Belastung, die zu nichts zwingt. Architektonische Entscheidungen sollten in solchen Phasen die Komplexität reduzieren, nicht ausweiten.

Aus DSGVO-Sicht ist die Hürde zudem hoch: in geschützten Settings (Pflege, Bildung, Gesundheit) ist die Validität freiwilliger Einwilligungen wegen impliziter Machtgefälle und Belastungssituationen besonders angreifbar. Selbst wenn die Personen einverstanden wären, wäre die Verarbeitung von Gesundheits- oder Verhaltensdaten Dritter durch Privatpersonen rechtlich heikel.

Aus Engineering-Sicht hat diese Entscheidung den Nebeneffekt, dass die Architektur radikal einfacher wird: kein Rollen-Modell, keine Sichtbarkeits-Layer, keine Owner-Felder, keine Multi-Tenant-Daten. Die Idee bleibt verfügbar — als zukünftige Erweiterung in einem anderen Kontext, sofern dort eine saubere rechtliche Grundlage geschaffen werden kann.

### 9.3 Tagebuch-Frequenz → täglich, mit automatisierter Aggregation

**Entscheidung:** Tägliche Einträge als Basis, mit automatischer Aggregation auf Wochen-, Monats- und perspektivisch Jahres-Ebene (siehe Abschnitt 4.1).

**Begründung:** Tägliche Einträge sind die einzig zuverlässige Frequenz, weil sie eine Routine sein können. Wöchentlich verleitet zum "ich schreibe das gleich nach"; ad hoc verleitet zum Vergessen. Die Aggregations-Skripte machen aus täglichen Mini-Einträgen über Zeit hinweg lesbare Längsschnitt-Berichte ohne manuellen Mehraufwand.

### 9.4 Strukturmodell-Formalität → UML 2.5 mit OCL-Constraints

**Entscheidung:** Strikt UML-konforme Modellierung mit dokumentierten OCL-Invarianten (siehe Abschnitt 4.2).

**Begründung:** Der pragmatische "schnell-mal-eben"-Ansatz produziert nach drei Wochen unleserliche Modelle, weil keine Konsistenz-Regeln existieren. Mit OCL hat man ein **wirkliches formales Modell** — auch ohne Tooling-basierte Validierung, allein durch die Selbst-Disziplin, die Constraints einzuhalten. Der Mehraufwand zahlt sich aus, sobald das Modell mehr als 10 Knoten hat.

---

## 10. Bewusste Entscheidung gegen bestimmte Ansätze

Was bei diesem Pattern bewusst **nicht** gemacht wird, und warum:

- **Kein Public-Repo.** Auch das anonymisierteste Strukturmodell ließe sich mit Luftbildern und Geländekenntnis dem konkreten Standort zuordnen.
- **Keine Klar­namen, auch nicht in privaten Notizen.** Pseudonyme als Default schützen vor versehentlichem Leak in falsche Schicht.
- **Keine direkten Fotos der Anlage im Repo.** EXIF-Daten enthalten oft GPS, Auflösung erlaubt Re-Identifikation, BLOB-Größe macht Repo unbrauchbar.
- **Keine Live-Sync-Tools** (z.B. Obsidian Sync) für Schicht 2/3. Alles, was synchronisiert, hat zusätzliche Angriffsflächen.
- **Keine KI-Tools mit Cloud-Anbindung** für Schicht 2/3 mit echten Inhalten. Sobald echte Schicht-3-Inhalte einer KI gefüttert werden, ist die Datenverarbeitungs-Kette nicht mehr unter eigener Kontrolle.

---

## 11. Fazit

Die Antwort auf die ursprüngliche Frage *"A + B + C in einer Suite, wie sauber aufbauen?"* lautet:

- **Ja, eine Suite** — ein Repo, eine Modellierungs-Werkzeugkette, eine Methodik.
- **Drei Schichten** mit unterschiedlichem Datenschutz-Niveau, weil A und B/C fundamental verschiedene Risikoprofile haben.
- **Pseudonymisierungs-Tabelle ab Tag 1** in Schicht 3 — der zentrale Mechanismus, der alle anderen Privacy-Maßnahmen erst praktikabel macht.
- **git-crypt für Schicht 2** — alles im Repo, transparent verschlüsselt.
- **Single-User by Design** — bewusst keine Multi-User-Komplexität.
- **UML 2.5 + OCL** — formal saubere Modellierung statt pragmatischer Notation.
- **Zeit-dimensionale Aggregation** — täglich gepflegt, automatisch verdichtet.
- **Privacy-by-Design** als bewusste Architektur-Entscheidung, nicht als nachgelagerter Filter.
- **Inkrementell** — Ontologie zuerst, grober Lageplan, dann Detaillierung. Das Modell wächst mit dem Erleben des Geländes.

Das Endergebnis nach einigen Wochen ist ein dreischichtiges Modell: ein lesbarer, formal sauberer Lageplan (Schicht 1), ein persönliches strukturiertes Tagebuch mit automatisch aggregierten Längsschnitten (Schicht 2), und ein separater verschlüsselter Speicherort für alles, was andere Menschen betrifft (Schicht 3) — mit klaren, jederzeit nachvollziehbaren Regeln, was wo hingehört.

Aus engineering-ästhetischer Sicht eine schöne Architektur. Aus persönlicher Sicht eine sinnvolle, strukturgebende Beschäftigung. Aus rechtlicher Sicht gangbar, sofern die Schicht-3-Disziplin und das Pseudonymisierungs-Verfahren konsequent gehalten werden.
