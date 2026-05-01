# PlantUML Cheatsheet

Schnellreferenz fuer die haeufigsten Syntax-Bausteine.
Vollstaendige Doku: <https://plantuml.com>

## Grundgeruest

````plantuml
@startuml DiagramName
title Mein Diagramm
' Kommentar mit Hochkomma am Zeilenanfang
@enduml
````

## Klassendiagramm

### Klasse mit Sichtbarkeiten

````plantuml
class Auto {
  + publicAttribut: String
  - privateAttribut: Integer
  # protectedAttribut: Boolean
  ~ packageAttribut: Double
  + publicMethode(): void
  + {static} statischeMethode(): void
  + {abstract} abstrakteMethode(): void
}
````

### Beziehungen

| Syntax       | Bedeutung                            |
|--------------|--------------------------------------|
| `A -- B`     | Assoziation                          |
| `A --> B`    | gerichtete Assoziation               |
| `A <|-- B`   | Vererbung (B erbt von A)             |
| `A *-- B`    | Komposition (A besteht aus B)        |
| `A o-- B`    | Aggregation (A hat B)                |
| `A ..> B`    | Abhaengigkeit (gestrichelt)          |
| `A <|.. B`   | Implementierung (B implementiert A)  |

### Multiplizitaeten + Rollen

````plantuml
Nutzer "1" -- "0..*" Bestellung : taetigt >
````

## Sequenzdiagramm

````plantuml
@startuml
actor User
participant App
database DB

User -> App: Anfrage
activate App
App -> DB: Query
DB --> App: Ergebnis
App --> User: Antwort
deactivate App

' Notes
note right of User: Wichtiger Hinweis

' Verzweigung
alt Erfolg
  App -> User: 200 OK
else Fehler
  App -> User: 500 Error
end

' Schleife
loop 3 mal
  App -> DB: Retry
end
@enduml
````

## Aktivitaetsdiagramm

````plantuml
@startuml
start
:Erste Aktion;

if (Bedingung?) then (ja)
  :Aktion A;
else (nein)
  :Aktion B;
endif

' Parallele Pfade
fork
  :Pfad 1;
fork again
  :Pfad 2;
end fork

' Schleife
while (mehr Daten?)
  :Verarbeite Datensatz;
endwhile (nein)

stop
@enduml
````

## Komponentendiagramm

````plantuml
@startuml
package "Frontend" {
  [Browser] as B
  [Mobile App] as M
}

package "Backend" {
  [API Gateway] as API
  interface "REST" as IRest
  API - IRest
}

database DB
cloud Internet

B --> Internet
M --> Internet
Internet --> IRest
API --> DB
@enduml
````

## Use-Case-Diagramm

````plantuml
@startuml
actor Kunde
actor Admin

rectangle Shopsystem {
  usecase "Produkt suchen"   as UC1
  usecase "Bestellen"        as UC2
  usecase "Bestellung pruefen" as UC3
}

Kunde --> UC1
Kunde --> UC2
Admin --> UC3
UC2 ..> UC1 : <<include>>
@enduml
````

## Zustandsdiagramm

````plantuml
@startuml
[*] --> Inaktiv
Inaktiv --> Aktiv : start
Aktiv --> Pausiert : pause
Pausiert --> Aktiv : resume
Aktiv --> [*] : stop
Pausiert --> [*] : abort
@enduml
````

## Stil-Anpassungen

### Themes (Vor-Definiert)

````plantuml
@startuml
!theme cerulean
' Andere: amiga, aws-orange, bluegray, carbon-gray, cyborg, hacker,
' mars, materia, plain, reddress-darkblue, sketchy, spacelab, sunlost
@enduml
````

### Skin-Parameter (Manuell)

````plantuml
skinparam backgroundColor #FEFEFE
skinparam class {
  BackgroundColor LightBlue
  BorderColor DarkBlue
  ArrowColor Black
}
````

## Includes (Wiederverwendung)

In einem `_shared/styles.iuml`:

````plantuml
@startuml
!define BRAND_COLOR #0066CC
skinparam ArrowColor BRAND_COLOR
@enduml
````

In jedem Diagramm verwenden:

````plantuml
@startuml
!include _shared/styles.iuml
class A
@enduml
````

## Diagramm-Layouting

| Direktive               | Wirkung                                 |
|-------------------------|-----------------------------------------|
| `left to right direction`  | Layout horizontal statt vertikal     |
| `top to bottom direction`  | Layout vertikal (Default)            |
| `together { A B }`         | A und B beieinander platzieren       |
| `hide empty members`       | Leere Methoden-/Attributboxen weg    |
| `hide circle`              | C/I/E-Klassenkreise ausblenden       |
