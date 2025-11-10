# LaTeX Labor-Protokoll Template

Eine einfache, strukturierte LaTeX-Vorlage für wissenschaftliche Labor-Protokolle mit interaktivem Setup-Script.

## Quick Start

1. **Repository klonen oder als Template verwenden:**
   ```bash
   git clone https://github.com/Probst1nator/LatexLabworksTemplate
   cd LatexLabworksTemplate
   ```

2. **Setup-Script ausführen:**
   ```bash
   chmod +x ./self_removing_setup_helper.sh
   ./self_removing_setup_helper.sh
   ```
   Das Script führt dich interaktiv durch alle notwendigen Eingaben und ersetzt die Platzhalter in `main.tex`.

3. **Dokument bearbeiten und kompilieren:**

   **Einfacher:** Nutze [Overleaf](https://www.overleaf.com) für einfaches Hosting mit deinem Uni-Login und für gemeinsame asynchrone und synchrone Zusammenarbeit.

   **Lokal:** Für vollständige lokale Verwaltung:
   ```bash
   pdflatex main.tex
   biber main
   pdflatex main.tex
   pdflatex main.tex
   ```

## Was ist enthalten?

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

- **self_removing_setup_helper.sh** - Interaktives Setup-Script
  - Ersetzt alle Platzhalter (Titel, Autoren, Daten, etc.)
  - Erstellt automatisch ein Backup
  - Speichert deine Eingaben für zukünftige Protokolle
  - Löscht sich selbst nach erfolgreicher Einrichtung

## Anforderungen

- LaTeX-Distribution (TeX Live, MiKTeX, etc.)
- `pdflatex` oder `xelatex`
- `biber` für Literaturverweise
- Bash (für das Setup-Script)

## Verwendung

### Mit Setup-Script (empfohlen)

Führe einfach `./self_removing_setup_helper.sh` aus und folge den Anweisungen.

### Manuell

Öffne `main.tex` und ersetze die Platzhalter in den Zeilen 12-27:
- `[Titel des Versuchs]`
- `[Name des Kurses oder Praktikums]`
- `[Ihr Studiengang]`
- etc.

## Anpassungen

Die Vorlage kann natürlich nach deinen Bedürfnissen angepasst werden:
- Pakete hinzufügen/entfernen in Zeilen 33-130
- Struktur anpassen (Kapitel hinzufügen/entfernen)
- Layout-Einstellungen ändern (Seitenränder, Schriftart, etc.)

## Features

### Intelligente Wertspeicherung

Das Setup-Script speichert deine Eingaben in `~/.cache/latex-labworks-template/last_values.cache`.

**Vorteile:**
- Bei mehreren Protokollen im gleichen Kurs musst du wiederkehrende Werte (Kurs, Studiengang, Hochschule, Autoren, etc.) nicht erneut eingeben
- Einfach Enter drücken, um den letzten Wert zu übernehmen
- Nur neue/geänderte Werte eingeben (z.B. Titel, Datum)

### Automatische Datumsberechnung

Das Abgabedatum wird automatisch als **2 Wochen nach dem Versuchsdatum** berechnet und vorgeschlagen. Du kannst den Vorschlag einfach mit Enter übernehmen oder ein anderes Datum eingeben.

**Cache löschen (optional):**
```bash
rm ~/.cache/latex-labworks-template/last_values.cache
```

## Tipps

- Akronyme werden automatisch beim ersten Gebrauch ausgeschrieben
- Abbildungen im Ordner `Abbildungen/` ablegen
- Literatur in `quellen.bib` eintragen und mit `\cite{key}` referenzieren
- Das Backup `main.tex.backup` kann gelöscht werden, sobald alles passt
- Für mehrere Protokolle: Template einfach erneut klonen, Script nutzt gecachte Werte

## Lizenz

Frei verwendbar für akademische Zwecke.
