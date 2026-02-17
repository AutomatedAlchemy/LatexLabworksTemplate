# LaTeX Labworks-Protokoll Vorlage

Eine strukturierte LaTeX-Vorlage für wissenschaftliche Labor-Protokolle inklusive eines Setup-Skripts zur automatisierten Erstellung neuer Projekt-Verzeichnisse.

## Schnellstart

1.  **Repository klonen und Skript ausführbar machen:**
    ```bash
    git clone https://github.com/Probst1nator/LatexLabworksTemplate
    cd LatexLabworksTemplate
    chmod +x init_new_project.sh
    ```
2.  **Setup-Skript ausführen:**
    ```bash
    ./init_new_project.sh
    ```
    Das Skript führt interaktiv durch die Konfiguration, ersetzt alle Platzhalter und erstellt ein neues Projekt-Verzeichnis.
3.  **Kompilieren:**
    *   **Cloud:** Das erstellte ZIP-Archiv einfach auf [Overleaf](https://www.overleaf.com) hochladen.
    *   **Lokal:** Im neuen Projekt-Ordner `pdflatex main.tex` ausführen.

## Hauptfunktionen

*   **Intelligentes Caching:** Speichert Eingaben wie Hochschule, Studiengang oder Kurs, um sie bei zukünftigen Protokollen per Tastendruck zu übernehmen.
*   **Datumsberechnung:** Konvertiert Datumsangaben in das deutsche Textformat und berechnet automatisch ein Abgabedatum (14 Tage nach Versuch).
*   **Zufallssortierung:** Autorennamen werden automatisch in eine zufällige Reihenfolge gebracht.
*   **ZIP-Export:** Erzeugt direkt ein ZIP-Archiv des neuen Projekts für den schnellen Upload.

## Projektstruktur

```text
.
├── init_new_project.sh           # Setup-Skript zur Projekt-Erstellung
├── .LatexLabworksTemplate.cache  # Cache-Datei für Benutzereingaben
├── LatexProjectTemplate/         # Basis-Vorlage (hier können Standard-Anpassungen vorgenommen werden)
└── [Dein_Kurs_Name]/             # Automatisch erstellter Projekt-Ordner
```

## Anpassungen

*   **Globale Änderungen:** Bearbeite die Dateien im Ordner `LatexProjectTemplate/`, um das Layout oder die Pakete für alle zukünftigen Projekte dauerhaft anzupassen.
*   **Projekt-spezifische Änderungen:** Bearbeite die `main.tex` im neu erstellten Projekt-Ordner, um individuelle Anpassungen nur für dieses eine Protokoll vorzunehmen.

## Anforderungen

*   **Skript:** Bash (sed, grep, date) und optional `zip`.
*   **Kompilierung:** Eine LaTeX-Distribution (TeX Live, MiKTeX) oder ein Overleaf-Account.