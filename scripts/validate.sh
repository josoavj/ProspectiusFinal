#!/bin/bash
# Script de validation de l'installation de Prospectius

set -e

echo "================================"
echo "Validation de Prospectius"
echo "================================"
echo ""

ERRORS=0

# Vérifier Flutter
echo "Vérification de Flutter..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "✓ Flutter: $FLUTTER_VERSION"
else
    echo "❌ Flutter non trouvé"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier MySQL
echo "Vérification de MySQL/MariaDB..."
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo "✓ MySQL: $MYSQL_VERSION"
    
    # Tester la connexion
    if mysql -u root -proot -e "SELECT 1" &> /dev/null; then
        echo "✓ Connexion MySQL fonctionnelle"
        
        # Vérifier la base Prospectius
        if mysql -u root -proot -e "USE Prospectius; SHOW TABLES;" &> /dev/null; then
            echo "✓ Base Prospectius trouvée"
        else
            echo "⚠ Base Prospectius non trouvée (peut être importée via install-*.sh)"
        fi
    else
        echo "❌ Impossible de se connecter à MySQL (user: root, password: root)"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "❌ MySQL/MariaDB non trouvé"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier les dépendances Flutter
echo "Vérification des dépendances Flutter..."
if [ -f "pubspec.yaml" ]; then
    if grep -q "mysql1:" pubspec.yaml && grep -q "provider:" pubspec.yaml; then
        echo "✓ pubspec.yaml valide"
    else
        echo "❌ pubspec.yaml incomplet (mysql1 ou provider manquant)"
        ERRORS=$((ERRORS + 1))
    fi
    
    if [ -d "pubspec.lock" ] || [ -f "pubspec.lock" ]; then
        echo "✓ Dépendances installées (pubspec.lock existe)"
    else
        echo "⚠ Dépendances non installées (exécutez: flutter pub get)"
    fi
else
    echo "❌ pubspec.yaml non trouvé"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier la structure des fichiers
echo "Vérification de la structure..."
REQUIRED_FILES=(
    "lib/main.dart"
    "lib/models/account.dart"
    "lib/models/prospect.dart"
    "lib/services/mysql_service.dart"
    "lib/providers/auth_provider.dart"
    "lib/screens/login_screen.dart"
)

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "✓ $FILE"
    else
        echo "❌ Fichier manquant: $FILE"
        ERRORS=$((ERRORS + 1))
    fi
done

# Résumé
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo "✓ Tous les contrôles passés!"
    echo "================================"
    echo ""
    echo "Pour démarrer l'application:"
    echo "  flutter run"
    exit 0
else
    echo "❌ $ERRORS erreur(s) détectée(s)"
    echo "================================"
    exit 1
fi
