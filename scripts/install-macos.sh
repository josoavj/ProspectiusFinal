#!/bin/bash
# Script d'installation de Prospectius sur macOS

set -e

echo "================================"
echo "Installation de Prospectius"
echo "================================"
echo ""

# Vérifier si Homebrew est installé
if ! command -v brew &> /dev/null; then
    echo "⚠ Homebrew n'est pas installé"
    echo ""
    echo "Installez Homebrew en exécutant:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✓ Homebrew détecté"
echo ""

# Vérifier et installer MariaDB
echo "Vérification de MariaDB..."

if ! command -v mysql &> /dev/null; then
    echo "⚠ MariaDB n'est pas installé"
    echo ""
    echo "Installation de MariaDB..."
    brew install mariadb
    
    echo "Initialisation de MariaDB..."
    brew services start mariadb
    sleep 2
    
    # Sécuriser l'installation MariaDB par défaut
    echo "Configuration initiale de MariaDB..."
    mysql_install_db --user=_mysql --datadir=/usr/local/var/mysql --tmpdir=/tmp 2>/dev/null || true
fi

# Démarrer MariaDB s'il n'est pas actif
if ! pgrep -x mysqld > /dev/null; then
    echo "Démarrage de MariaDB..."
    brew services start mariadb
    sleep 2
fi

echo "✓ MariaDB est actif"
echo ""

# Vérifier Flutter
echo "Vérification de Flutter..."

if ! command -v flutter &> /dev/null; then
    echo "⚠ Flutter n'est pas installé"
    echo ""
    echo "Téléchargez et installez Flutter:"
    echo "  https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

echo "✓ Flutter détecté"
echo ""

# Configurer la base de données
echo "Configuration de la base de données Prospectius..."
echo ""

# Télécharger le script SQL depuis GitHub
echo "Téléchargement du script SQL depuis GitHub..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITHUB_URL="https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql"

if command -v curl &> /dev/null; then
    curl -f -o "/tmp/Prospectius.sql" "$GITHUB_URL"
elif command -v wget &> /dev/null; then
    wget -O "/tmp/Prospectius.sql" "$GITHUB_URL"
else
    echo "⚠ Erreur: curl ou wget est requis"
    exit 1
fi

if [ ! -f "/tmp/Prospectius.sql" ]; then
    echo "⚠ Erreur lors du téléchargement du script SQL"
    echo ""
    echo "Vous pouvez le télécharger manuellement depuis:"
    echo "  $GITHUB_URL"
    exit 1
fi

# Importer le script SQL
echo "Importation du schéma de base de données..."

if mysql -u root < /tmp/Prospectius.sql; then
    echo "✓ Base de données configurée"
else
    echo "⚠ Impossible d'importer la base de données"
    echo ""
    echo "Vous pouvez essayer manuellement:"
    echo "  mysql -u root < /tmp/Prospectius.sql"
    exit 1
fi

echo ""

# Récupérer les dépendances Flutter
echo "Récupération des dépendances Flutter..."

if flutter pub get; then
    echo "✓ Dépendances installées"
else
    echo "⚠ Erreur lors de la récupération des dépendances"
    exit 1
fi

echo ""
echo "================================"
echo "✓ Installation terminée!"
echo "================================"
echo ""
echo "Pour lancer l'application:"
echo "  flutter run"
echo ""
echo "Configuration de la base de données au premier lancement:"
echo "  Host: localhost"
echo "  Port: 3306"
echo "  User: root"
echo "  Password: (laissez vide)"
echo "  Database: Prospectius"
echo ""
echo "Connexion par défaut:"
echo "  Utilisateur: admin"
echo "  Mot de passe: admin"
echo ""
