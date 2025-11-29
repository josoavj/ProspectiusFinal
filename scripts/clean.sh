#!/bin/bash
# Script de nettoyage et diagnostic de Prospectius

set -e

echo "================================"
echo "Prospectius: Cleanup & Diagnostic"
echo "================================"
echo ""

# Détecter le répertoire du projet
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Demander confirmation
echo "Ce script va nettoyer les fichiers temporaires et les caches de build."
echo ""
read -p "Continuer? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Annulation."
    exit 0
fi

echo ""
echo "Nettoyage..."
echo ""

# Nettoyer Flutter
if [ -d "build" ]; then
    echo "Suppression du répertoire build..."
    rm -rf build
fi

if [ -f "pubspec.lock" ]; then
    echo "Suppression de pubspec.lock..."
    rm -f pubspec.lock
fi

if [ -d ".dart_tool" ]; then
    echo "Suppression du répertoire .dart_tool..."
    rm -rf .dart_tool
fi

# Nettoyer les caches système
if [ -d "$HOME/.flutter" ]; then
    echo "Vérification du cache Flutter..."
    # Ne pas supprimer, juste afficher la taille
    FLUTTER_CACHE_SIZE=$(du -sh "$HOME/.flutter" 2>/dev/null | cut -f1)
    echo "  Taille du cache Flutter: $FLUTTER_CACHE_SIZE"
fi

# Réinstaller les dépendances
echo ""
echo "Réinstallation des dépendances Flutter..."
flutter pub get

# Afficher les informations de diagnostic
echo ""
echo "================================"
echo "Diagnostic"
echo "================================"
echo ""

echo "Version Flutter:"
flutter --version

echo ""
echo "Plateforme détectée:"
flutter doctor | head -n 15

echo ""
echo "Dépendances principales:"
grep -E "^\s*(provider|mysql1|shared_preferences|crypto|csv):" pubspec.yaml || echo "Aucune dépendance trouvée"

echo ""
echo "Structure du projet:"
echo "  - lib/: $(find lib -name '*.dart' | wc -l) fichiers Dart"
echo "  - test/: $(find test -name '*.dart' 2>/dev/null | wc -l) fichiers de test"
echo "  - scripts/: $(ls -1 scripts/ 2>/dev/null | wc -l) scripts"

echo ""
echo "Status de la base de données:"
if command -v mysql &> /dev/null; then
    if mysql -u root -proot -e "SELECT 1" &> /dev/null; then
        echo "  ✓ MySQL connecté"
        
        if mysql -u root -proot -e "USE Prospectius; SELECT COUNT(*) as tables FROM information_schema.tables WHERE table_schema='Prospectius';" 2>/dev/null | tail -n 1; then
            TABLES=$(mysql -u root -proot -e "USE Prospectius; SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='Prospectius';" 2>/dev/null | tail -n 1)
            echo "  ✓ Base Prospectius trouvée ($TABLES tables)"
        else
            echo "  ⚠ Base Prospectius non trouvée"
        fi
    else
        echo "  ❌ Impossible de se connecter à MySQL"
    fi
else
    echo "  ❌ MySQL non installé"
fi

echo ""
echo "================================"
echo "Cleanup terminé!"
echo "================================"
echo ""
echo "Prochaines étapes:"
echo "  1. Vérifier la configuration MariaDB (ENVIRONMENT.md)"
echo "  2. Lancer: flutter run"
echo "  3. Si problèmes: bash scripts/validate.sh"
echo ""
