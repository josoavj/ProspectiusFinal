#!/bin/bash
# Démarrage intelligent pour Prospectius - Détecte la plateforme et lance le bon script

set -e

echo "================================"
echo "Prospectius Setup"
echo "================================"
echo ""

# Détecter le système d'exploitation
OS_TYPE=$(uname -s)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

case "$OS_TYPE" in
    Linux*)
        echo "Plateforme détectée: Linux"
        echo ""
        bash "$SCRIPT_DIR/install-linux.sh"
        ;;
    Darwin*)
        echo "Plateforme détectée: macOS"
        echo ""
        bash "$SCRIPT_DIR/install-macos.sh"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "Plateforme détectée: Windows (Git Bash)"
        echo ""
        # Pour Windows via Git Bash
        if command -v powershell &> /dev/null; then
            echo "Lancement du script PowerShell..."
            powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/install-windows.ps1"
        else
            bash "$SCRIPT_DIR/install-windows.bat"
        fi
        ;;
    *)
        echo "❌ Système d'exploitation non reconnu: $OS_TYPE"
        exit 1
        ;;
esac

echo ""
echo "Pour démarrer l'application:"
echo "  cd \"$PROJECT_DIR\""
echo "  flutter run"
echo ""
