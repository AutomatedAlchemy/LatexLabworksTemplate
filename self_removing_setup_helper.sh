#!/bin/bash

# =============================================================================
# Self-Removing Setup Helper for LaTeX Lab Protocol Template
# =============================================================================
# This script interactively replaces placeholders in main.tex and then
# removes itself after completion (only if all placeholders were replaced).
# Features caching of previous values for convenience.
# =============================================================================

set -e  # Exit on error

# Colors for better readability
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MAIN_TEX="main.tex"
SCRIPT_NAME="$(basename "$0")"
ALL_REPLACED=true  # Track if all placeholders were replaced successfully

# Cache configuration
CACHE_DIR="$HOME/.cache/latex-labworks-template"
CACHE_FILE="$CACHE_DIR/last_values.txt"

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

    # Create cache directory if it doesn't exist
    mkdir -p "$CACHE_DIR"

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

    # Check if value is non-empty
    if [ -z "$user_input" ]; then
        ALL_REPLACED=false
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

    # Check if value is non-empty
    if [ -z "$user_input" ]; then
        ALL_REPLACED=false
    fi

    echo ""
}

# Function to replace text in main.tex
replace_in_file() {
    local search="$1"
    local replace="$2"
    local file="$3"

    # Escape special characters for sed
    search_escaped=$(printf '%s\n' "$search" | sed 's/[[\.*^$/]/\\&/g')
    replace_escaped=$(printf '%s\n' "$replace" | sed 's/[&/\]/\\&/g')

    # Check if replacement value is empty
    if [ -z "$replace" ]; then
        ALL_REPLACED=false
        return 1
    fi

    sed -i "s/$search_escaped/$replace_escaped/g" "$file"
    return 0
}

# =============================================================================
# Main Script
# =============================================================================

# Check if main.tex exists
if [ ! -f "$MAIN_TEX" ]; then
    print_error "Datei $MAIN_TEX nicht gefunden!"
    exit 1
fi

print_header

echo -e "Willkommen! Dieses Script hilft dir, die Vorlage für dein Labor-Protokoll"
echo -e "einzurichten. Du wirst nach verschiedenen Informationen gefragt."
echo ""
if [ -f "$CACHE_FILE" ]; then
    echo -e "${YELLOW}Hinweis: Drück einfach Enter, um die letzten Werte zu übernehmen.${NC}"
else
    echo -e "${YELLOW}Hinweis: Deine Eingaben werden für zukünftige Protokolle gespeichert.${NC}"
fi
echo ""
read -p "Drück Enter zum Fortfahren..." dummy
echo ""

# Create backup
print_step "Erstelle Backup von $MAIN_TEX..."
cp "$MAIN_TEX" "${MAIN_TEX}.backup"
print_success "Backup erstellt: ${MAIN_TEX}.backup"
echo ""

# =============================================================================
# Collect Information
# =============================================================================

print_step "Schritt 1/9: Titel des Versuchs"
ask_input "Wie lautet der Titel deines Versuchs?" "titel" TITEL

print_step "Schritt 2/9: Kurs/Praktikum"
ask_input "Name des Kurses oder Praktikums?" "kurs" KURS

print_step "Schritt 3/9: Studiengang"
ask_input "Dein Studiengang?" "studiengang" STUDIENGANG

print_step "Schritt 4/9: Hochschule und Fakultät"
ask_input "Name der Hochschule und Fakultät?" "hochschule" HOCHSCHULE

print_step "Schritt 5/9: Autoren"
print_info "Gib die Namen aller Autoren ein (getrennt durch Komma)"
ask_input "Autoren (z.B. Ezra Exam, Max Muster)?" "autoren" AUTOREN

print_step "Schritt 6/9: Versuchsdatum"
print_info "Format: dd.mm.yyyy (z.B. 10.11.2025)"
ask_input "Datum der Versuchsdurchführung?" "versuchsdatum" VERSUCHSDATUM

print_step "Schritt 7/9: Abgabedatum"
print_info "Format: dd.mm.yyyy (z.B. 24.11.2025)"
SUGGESTED_ABGABEDATUM=$(add_14_days "$VERSUCHSDATUM")
ask_input_with_default "Abgabedatum des Protokolls?" "$SUGGESTED_ABGABEDATUM" ABGABEDATUM

print_step "Schritt 8/9: Betreuer"
ask_input "Name(n) der Versuchsbetreuer?" "betreuer" BETREUER

print_step "Schritt 9/9: Stichwörter"
print_info "Gib 2-3 spezifische Stichwörter für deinen Versuch ein"
print_info "Diese werden für die PDF-Metadaten verwendet"
ask_input "Stichwörter (z.B. Optik, Beugung)?" "stichworte" STICHWORTE

# =============================================================================
# Validate all inputs are non-empty
# =============================================================================

if [ -z "$TITEL" ] || [ -z "$KURS" ] || [ -z "$STUDIENGANG" ] || \
   [ -z "$HOCHSCHULE" ] || [ -z "$AUTOREN" ] || [ -z "$VERSUCHSDATUM" ] || \
   [ -z "$ABGABEDATUM" ] || [ -z "$BETREUER" ] || [ -z "$STICHWORTE" ]; then
    ALL_REPLACED=false
fi

# =============================================================================
# Apply Replacements
# =============================================================================

echo ""
print_step "Wende Änderungen auf $MAIN_TEX an..."
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

replace_in_file "[Stichwort 1], [Stichwort 2]" "$STICHWORTE" "$MAIN_TEX" && print_success "Stichwörter ersetzt"

# =============================================================================
# Completion
# =============================================================================

echo ""
if [ "$ALL_REPLACED" = true ]; then
    echo -e "${GREEN}${BOLD}==========================================================================="
    echo "  ✓ Setup erfolgreich abgeschlossen!"
    echo "===========================================================================${NC}"
else
    echo -e "${YELLOW}${BOLD}==========================================================================="
    echo "  ⚠ Setup mit Warnungen abgeschlossen!"
    echo "===========================================================================${NC}"
    print_warning "Einige Platzhalter wurden möglicherweise nicht vollständig ersetzt."
fi

echo ""
echo -e "Deine Vorlage wurde personalisiert und ist bereit zur Verwendung."
echo -e "Ein Backup der Originaldatei befindet sich in: ${BOLD}${MAIN_TEX}.backup${NC}"
echo ""
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "  1. Kompiliere main.tex mit pdflatex/xelatex"
echo -e "  2. Führe biber aus für die Literaturverweise"
echo -e "  3. Kompiliere erneut für das finale PDF"
echo ""

# =============================================================================
# Self-Removal (only if all placeholders were replaced)
# =============================================================================

if [ "$ALL_REPLACED" = true ]; then
    echo -e "${YELLOW}${BOLD}Alle Platzhalter wurden ersetzt.${NC}"
    read -p "Möchtest du dieses Skript entfernen? (y)/n: " confirm

    if [[ "$confirm" =~ ^[jJyY]$ ]] || [[ -z "$confirm" ]]; then
        echo ""
        print_step "Lösche $SCRIPT_NAME..."

        # Remove the script
        rm -- "$0"

        echo -e "${GREEN}${BOLD}✓ Setup-Script wurde entfernt.${NC}"
        echo ""
        echo -e "Viel Erfolg mit deinem Protokoll!"
        echo -e "${BLUE}Deine Eingaben wurden in ${CACHE_FILE} gespeichert.${NC}"
    else
        echo ""
        print_info "Setup-Script wurde NICHT gelöscht."
        echo -e "Du kannst es später manuell löschen: ${BOLD}rm $SCRIPT_NAME${NC}"
    fi
else
    echo -e "${YELLOW}${BOLD}Setup-Script wird NICHT automatisch gelöscht.${NC}"
    echo -e "Grund: Nicht alle Platzhalter wurden erfolgreich ersetzt."
    echo ""
    print_info "Bitte überprüfe $MAIN_TEX und führe das Script erneut aus,"
    echo -e "oder lösche es manuell: ${BOLD}rm $SCRIPT_NAME${NC}"
fi

echo ""
