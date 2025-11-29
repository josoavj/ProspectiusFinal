#!/bin/bash
# Télécharger le script SQL du dépôt dbProspectius

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_FILE="$SCRIPT_DIR/prospectius.sql"
GITHUB_URL="https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql"

echo "Téléchargement du schéma de base de données..."
echo "Source: $GITHUB_URL"
echo "Destination: $OUTPUT_FILE"
echo ""

if command -v curl &> /dev/null; then
    curl -f -o "$OUTPUT_FILE" "$GITHUB_URL"
elif command -v wget &> /dev/null; then
    wget -O "$OUTPUT_FILE" "$GITHUB_URL"
else
    echo "❌ Erreur: curl ou wget est requis"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "✓ Téléchargement réussi"
    echo ""
    echo "Pour importer le schéma:"
    echo "  mysql -u root -proot < $OUTPUT_FILE"
else
    echo "❌ Erreur lors du téléchargement"
    exit 1
fi
