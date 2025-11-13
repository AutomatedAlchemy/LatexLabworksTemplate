#!/bin/bash

# =============================================================================
# Setup Helper for LaTeX Lab Protocol Template
# =============================================================================
# This script creates a new project directory based on your course name,
# copies the template files, and replaces all placeholders with your inputs.
# Features caching of previous values for convenience across multiple projects.
# =============================================================================

set -e  # Exit on error

# Colors for better readability
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TEMPLATE_DIR="LatexProjectTemplate"
SCRIPT_NAME="$(basename "$0")"

# Cache configuration (stored in repository root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_FILE="$SCRIPT_DIR/.LatexLabworksTemplate.cache"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "==========================================================================="
    echo "  LaTeX Labor-Protokoll Template - Setup Assistent"
    echo "==========================================================================="
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}${BOLD}→ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Fehler: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warnung: $1${NC}"
}

# Convert dd.mm.yyyy to German text format (e.g., 05.11.2025 -> 5. November 2025)
format_date_german() {
    local date_input="$1"

    # Return empty if input is empty
    if [ -z "$date_input" ]; then
        echo ""
        return
    fi

    # Convert dd.mm.yyyy to yyyy-mm-dd for date command
    local day=$(echo "$date_input" | cut -d'.' -f1)
    local month=$(echo "$date_input" | cut -d'.' -f2)
    local year=$(echo "$date_input" | cut -d'.' -f3)
    local iso_date="$year-$month-$day"

    # Use date command with German locale (%-d removes leading zero)
    LC_TIME=de_DE.UTF-8 date -d "$iso_date" "+%-d. %B %Y" 2>/dev/null
}

# Add 14 days to a date in dd.mm.yyyy format and return in same format
add_14_days() {
    local date_input="$1"

    # Return empty if input is empty
    if [ -z "$date_input" ]; then
        echo ""
        return
    fi

    # Use date command with the format YYYY-MM-DD which it understands
    # Convert dd.mm.yyyy to yyyy-mm-dd
    local day=$(echo "$date_input" | cut -d'.' -f1)
    local month=$(echo "$date_input" | cut -d'.' -f2)
    local year=$(echo "$date_input" | cut -d'.' -f3)

    local iso_date="$year-$month-$day"

    # Add 14 days
    local new_date=$(date -d "$iso_date + 14 days" "+%d.%m.%Y" 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo ""
        return
    fi

    echo "$new_date"
}

# Load cached value for a given key
get_cached_value() {
    local key="$1"
    if [ -f "$CACHE_FILE" ]; then
        grep "^${key}=" "$CACHE_FILE" 2>/dev/null | cut -d'=' -f2- || echo ""
    else
        echo ""
    fi
}

# Save value to cache
save_to_cache() {
    local key="$1"
    local value="$2"

    # Create or update cache file
    if [ -f "$CACHE_FILE" ]; then
        # Remove old entry if exists, then append new one
        grep -v "^${key}=" "$CACHE_FILE" > "${CACHE_FILE}.tmp" 2>/dev/null || touch "${CACHE_FILE}.tmp"
        echo "${key}=${value}" >> "${CACHE_FILE}.tmp"
        mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
    else
        echo "${key}=${value}" > "$CACHE_FILE"
    fi
}

# Function to ask for user input with cached default value
ask_input() {
    local prompt="$1"
    local cache_key="$2"
    local variable_name="$3"
    local user_input
    local cached_value

    # Get cached value if available
    cached_value=$(get_cached_value "$cache_key")

    if [ -n "$cached_value" ]; then
        echo -e "${BOLD}$prompt${NC}"
        echo -e "  (Letzter Wert: ${YELLOW}$cached_value${NC})"
        read -p "  > " user_input
        if [ -z "$user_input" ]; then
            user_input="$cached_value"
        fi
    else
        echo -e "${BOLD}$prompt${NC}"
        read -p "  > " user_input
        while [ -z "$user_input" ]; do
            print_error "Eingabe darf nicht leer sein!"
            read -p "  > " user_input
        done
    fi

    eval "$variable_name=\"$user_input\""

    # Save to cache (only if cache_key is not empty)
    if [ -n "$cache_key" ]; then
        save_to_cache "$cache_key" "$user_input"
    fi

    echo ""
}

# Function to ask for input with a calculated default (doesn't cache)
ask_input_with_default() {
    local prompt="$1"
    local default_value="$2"
    local variable_name="$3"
    local user_input

    if [ -n "$default_value" ]; then
        echo -e "${BOLD}$prompt${NC}"
        echo -e "  (Vorschlag: ${YELLOW}$default_value${NC})"
        read -p "  > " user_input
        if [ -z "$user_input" ]; then
            user_input="$default_value"
        fi
    else
        echo -e "${BOLD}$prompt${NC}"
        read -p "  > " user_input
        while [ -z "$user_input" ]; do
            print_error "Eingabe darf nicht leer sein!"
            read -p "  > " user_input
        done
    fi

    eval "$variable_name=\"$user_input\""

    echo ""
}

# Function to replace text in a file
replace_in_file() {
    local search="$1"
    local replace="$2"
    local file="$3"

    # Escape special characters for sed
    search_escaped=$(printf '%s\n' "$search" | sed 's/[[\.*^$/]/\\&/g')
    replace_escaped=$(printf '%s\n' "$replace" | sed 's/[&/\]/\\&/g')

    # Check if replacement value is empty
    if [ -z "$replace" ]; then
        return 1
    fi

    sed -i "s/$search_escaped/$replace_escaped/g" "$file"
    return 0
}

# Sanitize project title to create a valid directory name
sanitize_dirname() {
    local input="$1"
    # Replace all special characters (including periods) with underscores
    # Keep only alphanumeric characters (a-zA-Z0-9) and replace everything else with _
    echo "$input" | sed 's/[^a-zA-Z0-9]/_/g'
}

# =============================================================================
# Main Script
# =============================================================================

# Check if template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    print_error "Template-Verzeichnis $TEMPLATE_DIR nicht gefunden!"
    exit 1
fi

print_header

echo -e "Willkommen! Dieses Script erstellt ein neues Projekt-Verzeichnis für dein"
echo -e "Labor-Protokoll und richtet alle Dateien mit deinen Angaben ein."
echo ""
if [ -f "$CACHE_FILE" ]; then
    echo -e "${YELLOW}Hinweis: Drück einfach Enter, um die letzten Werte zu übernehmen.${NC}"
else
    echo -e "${YELLOW}Hinweis: Deine Eingaben werden für zukünftige Protokolle gespeichert.${NC}"
fi
echo ""

# =============================================================================
# Collect Information
# =============================================================================

print_step "Schritt 1/8: Titel des Versuchs"
ask_input "Wie lautet der Titel deines Versuchs?" "titel" TITEL

print_step "Schritt 2/8: Kurs/Praktikum"
ask_input "Name des Kurses oder Praktikums?" "kurs" KURS

# Create project directory based on course name
PROJECT_DIR=$(sanitize_dirname "$KURS")
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="NeuesProjekt"
fi

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    print_error "Verzeichnis '$PROJECT_DIR' existiert bereits!"
    read -p "Möchtest du einen anderen Namen verwenden? (y/n): " confirm
    if [[ "$confirm" =~ ^[jJyY]$ ]]; then
        read -p "Neuer Verzeichnisname: " PROJECT_DIR
        while [ -d "$PROJECT_DIR" ] || [ -z "$PROJECT_DIR" ]; do
            print_error "Ungültiger oder bereits existierender Name!"
            read -p "Verzeichnisname: " PROJECT_DIR
        done
    else
        print_error "Abbruch."
        exit 1
    fi
fi

print_step "Schritt 3/8: Studiengang"
ask_input "Dein Studiengang?" "studiengang" STUDIENGANG

print_step "Schritt 4/8: Hochschule und Fakultät"
ask_input "Name der Hochschule und Fakultät?" "hochschule" HOCHSCHULE

print_step "Schritt 5/8: Autoren"
ask_input "Autoren (z.B. Ezra Exam, Max Muster)?" "autoren" AUTOREN

print_step "Schritt 6/8: Versuchsdatum"
ask_input "Datum (dd.mm.yyyy) der Versuchsdurchführung?" "versuchsdatum" VERSUCHSDATUM

print_step "Schritt 7/8: Abgabedatum"
SUGGESTED_ABGABEDATUM=$(add_14_days "$VERSUCHSDATUM")
ask_input_with_default "Abgabedatum (dd.mm.yyyy) des Protokolls?" "$SUGGESTED_ABGABEDATUM" ABGABEDATUM

print_step "Schritt 8/8: Betreuer"
ask_input "Name(n) der Versuchsbetreuer?" "betreuer" BETREUER

# =============================================================================
# Create Project Directory and Copy Template
# =============================================================================

echo ""
print_step "Erstelle Projekt-Verzeichnis: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
print_success "Verzeichnis erstellt"

echo ""
print_step "Kopiere Template-Dateien..."
cp -r "$TEMPLATE_DIR"/* "$PROJECT_DIR"/
print_success "Template-Dateien kopiert"

# The main.tex file is now in the project directory
MAIN_TEX="$PROJECT_DIR/main.tex"

# =============================================================================
# Apply Replacements
# =============================================================================

echo ""
print_step "Wende Änderungen auf main.tex an..."
echo ""

replace_in_file "[Titel des Versuchs]" "$TITEL" "$MAIN_TEX" && print_success "Titel ersetzt"

replace_in_file "[Name des Kurses oder Praktikums]" "$KURS" "$MAIN_TEX" && print_success "Kurs/Praktikum ersetzt"

replace_in_file "[Ihr Studiengang]" "$STUDIENGANG" "$MAIN_TEX" && print_success "Studiengang ersetzt"

replace_in_file "[Name der Hochschule und Fakultät]" "$HOCHSCHULE" "$MAIN_TEX" && print_success "Hochschule ersetzt"

replace_in_file "[Name 1], [Name 2], [Name 3]" "$AUTOREN" "$MAIN_TEX" && print_success "Autoren ersetzt"

# Replace both date placeholders individually (convert to German text format)
if [ -n "$VERSUCHSDATUM" ]; then
    VERSUCHSDATUM_FORMATTED=$(format_date_german "$VERSUCHSDATUM")
    sed -i "0,/TT. Monat JJJJ/s/TT. Monat JJJJ/$VERSUCHSDATUM_FORMATTED/" "$MAIN_TEX"
    print_success "Versuchsdatum ersetzt"
fi

if [ -n "$ABGABEDATUM" ]; then
    ABGABEDATUM_FORMATTED=$(format_date_german "$ABGABEDATUM")
    sed -i "0,/TT. Monat JJJJ/s/TT. Monat JJJJ/$ABGABEDATUM_FORMATTED/" "$MAIN_TEX"
    print_success "Abgabedatum ersetzt"
fi

replace_in_file "[Name des Betreuers]" "$BETREUER" "$MAIN_TEX" && print_success "Betreuer ersetzt"

# =============================================================================
# Completion
# =============================================================================

echo ""
echo -e "${GREEN}${BOLD}==========================================================================="
echo "  ✓ Setup erfolgreich abgeschlossen!"
echo "===========================================================================${NC}"

echo ""
echo -e "Dein neues Projekt wurde erstellt: ${BOLD}${PROJECT_DIR}/${NC}"
echo ""
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "  ${BOLD}Empfehlung (Cloud):${NC} Lade das Verzeichnis ${BOLD}$PROJECT_DIR/${NC} auf ${BOLD}overleaf.com${NC} hoch"
echo -e "  → Cloud Verfügbarkeit für gemeinsame Zusammenarbeit"
echo -e "  → Unbegrenzte Kompilierressourcen mit deinem Uni-Login"
echo ""
echo -e "  ${BOLD}Alternativ (Lokal):${NC}"
echo -e "  0. LaTeX-Distribution installieren (falls noch nicht vorhanden):"
echo -e "     - Linux: sudo apt install texlive-full"
echo -e "     - macOS: brew install --cask mactex"
echo -e "     - Windows: https://miktex.org"
echo -e "  1. cd $PROJECT_DIR"
echo -e "  2. Kompilierung:"
echo -e "     - Linux/macOS: pdflatex main.tex && biber main && pdflatex main.tex && pdflatex main.tex"
echo -e "     - Windows CMD: pdflatex main.tex & biber main & pdflatex main.tex & pdflatex main.tex"
echo ""
echo -e "${BLUE}Für weitere Projekte führe dieses Script einfach erneut aus!${NC}"
echo -e "${BLUE}Deine Eingaben wurden in ${CACHE_FILE} gespeichert.${NC}"
echo ""

# Get absolute path of created project directory
PROJECT_ABS_PATH="$(cd "$PROJECT_DIR" && pwd)"
echo -e "${BOLD}Absoluter Projekt Pfad:${NC} $PROJECT_ABS_PATH"
echo ""
