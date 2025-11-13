# LaTeX Labor-Protokoll Template

Eine einfache, strukturierte LaTeX-Vorlage für wissenschaftliche Labor-Protokolle mit interaktivem Setup-Script, das automatisch für jedes neue Protokoll ein separates Projekt-Verzeichnis erstellt.

## Quick Start

1. **Repository klonen oder als Template verwenden:**
   ```bash
   git clone https://github.com/Probst1nator/LatexLabworksTemplate
   cd LatexLabworksTemplate
   ```

2. **Setup-Script ausführen:**
   ```bash
   chmod +x ./init_new_project.sh
   ./init_new_project.sh
   ```
   Das Script führt dich interaktiv durch alle notwendigen Eingaben, erstellt automatisch ein neues Projekt-Verzeichnis basierend auf deinem Kursnamen, und ersetzt alle Platzhalter in den Template-Dateien.

3. **Ins Projekt-Verzeichnis wechseln und Dokument kompilieren:**

   **Einfacher:** Lade das erstellte Projekt-Verzeichnis in [Overleaf](https://www.overleaf.com) für einfaches Hosting mit deinem Uni-Login und für gemeinsame asynchrone und synchrone Zusammenarbeit.

   **Lokal:** Für vollständige lokale Verwaltung:
   ```bash
   cd DeinProjektname/
   pdflatex main.tex
   biber main
   pdflatex main.tex
   pdflatex main.tex
   ```

## Repository-Struktur

```
LatexLabworksTemplate/
├── init_new_project.sh              # Interaktives Setup-Script
├── LatexProjectTemplate/            # Basis-Template (NICHT direkt bearbeiten!)
│   ├── main.tex                     # LaTeX-Hauptdatei mit Platzhaltern
│   ├── quellen.bib                  # Literaturverwaltung
│   └── Abbildungen/                 # Ordner für Grafiken
└── [Deine Projekte]/                # Automatisch erstellte Projekt-Verzeichnisse
    └── ...
```

## Was passiert beim Setup?

Das Setup-Script:
1. Fragt nach allen wichtigen Informationen (Titel, Autoren, Daten, etc.)
2. Erstellt ein neues Verzeichnis basierend auf deinem Kursnamen
3. Kopiert alle Template-Dateien aus `LatexProjectTemplate/` ins neue Projekt
4. Ersetzt alle Platzhalter in der `main.tex` mit deinen Angaben
5. Speichert deine Eingaben für zukünftige Projekte

**Beispiel:**
- Du gibst als Kurs ein: "Physikalisches Praktikum 2"
- Script erstellt Verzeichnis: `PhysikalischesPraktikum2/`
- Du kannst sofort in diesem Verzeichnis weiterarbeiten

## Was ist im Template enthalten?

- **main.tex** - Vollständige Protokoll-Vorlage mit:
  - Deckblatt
  - Inhaltsverzeichnis, Abbildungs- und Tabellenverzeichnis
  - Abkürzungsverzeichnis
  - Vorkonfigurierte Pakete für Mathematik, Physik, Chemie
  - Strukturierte Kapitel (Einleitung, Grundlagen, Durchführung, Ergebnisse, Zusammenfassung)
  - Literaturverzeichnis (BibLaTeX)
  - Anhang

- **quellen.bib** - Datei für Literaturverweise

- **Abbildungen/** - Ordner für Grafiken und Bilder

## Anforderungen

- LaTeX-Distribution (TeX Live, MiKTeX, etc.)
- `pdflatex` oder `xelatex`
- `biber` für Literaturverweise
- Bash (für das Setup-Script)

## Features

### Intelligente Wertspeicherung

Das Setup-Script speichert deine Eingaben in `.LatexLabworksTemplate.cache` im Repository-Root.

**Vorteile:**
- Bei mehreren Protokollen im gleichen Kurs musst du wiederkehrende Werte (Kurs, Studiengang, Hochschule, Autoren, etc.) nicht erneut eingeben
- Einfach Enter drücken, um den letzten Wert zu übernehmen
- Nur neue/geänderte Werte eingeben (z.B. Titel, Datum)
- Cache bleibt lokal im Repository (nicht im Home-Verzeichnis verstreut)

### Automatische Datumsberechnung

Das Abgabedatum wird automatisch als **2 Wochen nach dem Versuchsdatum** berechnet und vorgeschlagen. Du kannst den Vorschlag einfach mit Enter übernehmen oder ein anderes Datum eingeben.

**Cache löschen (optional):**
```bash
rm .LatexLabworksTemplate.cache
```

### Separate Projekt-Verzeichnisse

Jedes neue Protokoll erhält sein eigenes Verzeichnis:
- Keine Überschreibung bestehender Arbeit
- Klare Organisation mehrerer Protokolle
- Einfaches Verwalten in Git (jedes Projekt kann separat versioniert werden)

## Anpassungen

### Template anpassen

Das Basis-Template befindet sich in `LatexProjectTemplate/`. Du kannst es nach deinen Bedürfnissen anpassen:

1. **Manuelle Anpassung:**
   ```bash
   cd LatexProjectTemplate/
   # Bearbeite main.tex nach deinen Wünschen
   # Pakete hinzufügen/entfernen (Zeilen 33-130)
   # Struktur anpassen (Kapitel hinzufügen/entfernen)
   # Layout-Einstellungen ändern (Seitenränder, Schriftart, etc.)
   ```

2. **Neue Projekte nutzen deine Anpassungen:**
   - Alle zukünftigen Projekte werden mit deinem angepassten Template erstellt
   - Bestehende Projekte bleiben unverändert

### Projekt-spezifische Anpassungen

Änderungen an einem erstellten Projekt-Verzeichnis beeinflussen nur dieses eine Projekt.

## Workflow für mehrere Protokolle

```bash
# Erstes Protokoll (z.B. für "Physikalisches Praktikum 1")
./init_new_project.sh
# → Erstellt z.B. "PhysikalischesPraktikum1/" mit allen Dateien

# Zweites Protokoll (z.B. für "Physikalisches Praktikum 2")
./init_new_project.sh
# → Erstellt z.B. "PhysikalischesPraktikum2/" mit allen Dateien

# Drittes Protokoll (z.B. für "Chemie Labor")
./init_new_project.sh
# → Erstellt z.B. "ChemieLabor/" mit allen Dateien
```

Jedes Projekt ist vollständig unabhängig!

## Tipps

- Akronyme werden automatisch beim ersten Gebrauch ausgeschrieben
- Abbildungen im jeweiligen Projekt-Ordner unter `Abbildungen/` ablegen
- Literatur in `quellen.bib` eintragen und mit `\cite{key}` referenzieren
- Das Backup `main.tex.backup` kann in jedem Projekt gelöscht werden, sobald alles passt
- Das Setup-Script bleibt im Repository und kann beliebig oft ausgeführt werden
- Template-Anpassungen in `LatexProjectTemplate/` wirken sich nur auf neue Projekte aus

## Lizenz

Frei verwendbar für akademische Zwecke.
