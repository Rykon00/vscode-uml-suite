# Case Studies

Dokumentierte Anwendungs-Pattern fuer die UML-Diagram-Suite.
Jede Case Study beschreibt ein konkretes Architektur-Problem,
die getroffenen Entscheidungen und die Begruendung dahinter.

## Index

- [01-three-layer-private-modeling.md](01-three-layer-private-modeling.md)
  Drei-Schichten-Privacy-Modellierung fuer persoenliche Projekte
  in sensiblen Settings (Pflege, Bildung, geschlossene Communities).
  Themen: Daten-Klassifikation, git-crypt, Pseudonymisierung,
  UML 2.5 mit OCL, zeit-dimensionale Tagebuch-Aggregation.

## Aufbau einer Case Study

Empfohlene Struktur fuer neue Eintraege:

1. **Zusammenfassung** -- Problem in 3-5 Saetzen
2. **Risiko-Analyse** -- was ist heikel, warum
3. **Datenmodell / Architektur** -- die Loesung
4. **Repo-Struktur** -- wie sieht das konkret aus
5. **Werkzeug-Empfehlungen** -- mit Begruendung
6. **Privacy/Praktiken im Alltag** -- wenn relevant
7. **Methodik** -- Iterationen / Reihenfolge
8. **Erste Schritte** -- Setup-Anleitung
9. **Getroffene Entscheidungen** -- mit Begruendungen
10. **Bewusste Entscheidung gegen Ansaetze** -- was nicht und warum
11. **Fazit**

Nicht jede Case Study muss alle Sektionen haben.
Die Struktur ist Empfehlung, nicht Vorschrift.

## Numerierung

Case Studies werden zwei-stellig numeriert (`01-`, `02-`, ...) und
in der Reihenfolge ihrer Aufnahme indexiert. Bei thematisch verwandten
Studies kann ein Sub-Index verwendet werden (`02a-`, `02b-`).