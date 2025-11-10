# LaTeX Labor-Protokoll Template

Eine einfache, strukturierte LaTeX-Vorlage für wissenschaftliche Labor-Protokolle mit interaktivem Setup-Script.

## Quick Start

1. **Repository klonen oder als Template verwenden:**
   ```bash
   git clone <repository-url>
   cd LatexLabworksTemplate
   ```

2. **Setup-Script ausführen:**
   ```bash
   ./self_removing_setup_helper.sh
   ```
   Das Script führt dich interaktiv durch alle notwendigen Eingaben und ersetzt die Platzhalter in `main.tex`.

3. **Dokument kompilieren:**
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

## Tipps

- Akronyme werden automatisch beim ersten Gebrauch ausgeschrieben
- Abbildungen im Ordner `Abbildungen/` ablegen
- Literatur in `quellen.bib` eintragen und mit `\cite{key}` referenzieren
- Das Backup `main.tex.backup` kann gelöscht werden, sobald alles passt

## Lizenz

Frei verwendbar für akademische Zwecke.
