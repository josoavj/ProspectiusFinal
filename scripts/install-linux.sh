#!/bin/bash

# Script d'installation de Prospectius sur Linux

set -e  # Quitter si une erreur se produit

echo "================================"
echo "Installation de Prospectius"
echo "================================"
echo ""

# Vérifier si MariaDB est installé
if ! command -v mariadb &> /dev/null; then
    echo "⚠️  MariaDB n'est pas installé"
    echo ""
    echo "Installation des dépendances:"
    echo ""
    
    # Déterminer la distribution Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
            echo "Exécutez sur Ubuntu/Debian:"
            echo "  sudo apt update"
            echo "  sudo apt install mariadb-server mariadb-client"
        elif [ "$ID" = "fedora" ] || [ "$ID" = "rhel" ] || [ "$ID" = "centos" ]; then
            echo "Exécutez sur Fedora/RHEL/CentOS:"
            echo "  sudo dnf install mariadb mariadb-common mariadb-server"
        elif [ "$ID" = "arch" ]; then
            echo "Exécutez sur Arch Linux:"
            echo "  sudo pacman -S mariadb"
        fi
    fi
    exit 1
fi

echo "✓ MariaDB détecté"
echo ""

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter n'est pas installé"
    echo "Téléchargez Flutter depuis: https://flutter.dev/docs/get-started/install/linux"
    exit 1
fi

echo "✓ Flutter détecté"
echo ""

# Démarrer MariaDB s'il n'est pas en cours d'exécution
if ! pgrep -x "mariadb" > /dev/null; then
    echo "Démarrage de MariaDB..."
    sudo systemctl start mariadb || true
    sleep 2
fi

echo "✓ MariaDB actif"
echo ""

# Importer la base de données
echo "Configuration de la base de données Prospectius..."
echo ""

# Vérifier si le script SQL existe
if [ ! -f "scripts/prospectius.sql" ]; then
    echo "⚠️  Script SQL non trouvé: scripts/prospectius.sql"
    echo ""
    echo "Téléchargez le script depuis:"
    echo "  https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql"
    echo ""
    echo "Et placez-le dans: scripts/prospectius.sql"
    exit 1
fi

# Importer le script SQL
mariadb -u root -p < scripts/prospectius.sql 2>/dev/null || {
    echo "Importation avec mot de passe par défaut..."
    mariadb -u root -proot < scripts/prospectius.sql
}

echo "✓ Base de données configurée"
echo ""

# Récupérer les dépendances Flutter
echo "Récupération des dépendances Flutter..."
flutter pub get
echo "✓ Dépendances installées"
echo ""

echo "================================"
echo "✓ Installation terminée!"
echo "================================"
echo ""
echo "Pour lancer l'application:"
echo "  flutter run -d linux"
echo ""
echo "Configuration de la base de données au premier lancement:"
echo "  Host: localhost"
echo "  Port: 3306"
echo "  User: root"
echo "  Password: root"
echo "  Database: Prospectius"
