#!/bin/bash

# Script d'installation de Prospectius sur Linux
# Télécharge l'exécutable Linux et le schéma SQL depuis la latest release GitHub

set -e  # Quitter si une erreur se produit

echo "================================"
echo "Installation de Prospectius"
echo "================================"
echo ""

# Créer le dossier de destination
mkdir -p temp_download

# Télécharger les fichiers depuis la latest release GitHub
echo "Téléchargement des fichiers depuis GitHub..."
echo ""

# Déterminer l'outil de téléchargement
DOWNLOAD_CMD=""
if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -L -o"
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -O"
else
    echo "⚠️  curl ou wget n'est pas installé"
    exit 1
fi

# Télécharger les URLs depuis l'API GitHub
echo "  Récupération des informations de la release..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/josoavj/ProspectiusFinal/releases/latest)

# Télécharger prospectius
EXE_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url":"[^"]*prospectius[^"]*"' | grep -v ".exe" | head -1 | cut -d'"' -f4)
if [ -n "$EXE_URL" ]; then
    echo "  Téléchargement de prospectius..."
    $DOWNLOAD_CMD temp_download/prospectius "$EXE_URL"
    chmod +x temp_download/prospectius
    echo "  ✓ prospectius téléchargé"
else
    echo "  ⚠️  prospectius non trouvé dans la release"
fi

# Télécharger Prospectius.sql
SQL_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url":"[^"]*Prospectius.sql[^"]*"' | head -1 | cut -d'"' -f4)
if [ -n "$SQL_URL" ]; then
    echo "  Téléchargement de Prospectius.sql..."
    $DOWNLOAD_CMD temp_download/Prospectius.sql "$SQL_URL"
    echo "  ✓ Prospectius.sql téléchargé"
else
    echo "  ⚠️  Prospectius.sql non trouvé dans la release"
    exit 1
fi

echo "✓ Fichiers téléchargés avec succès"
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
if [ ! -f "temp_download/Prospectius.sql" ]; then
    echo "⚠️  Script SQL n'a pas pu être téléchargé"
    echo ""
    echo "Vérifiez votre connexion Internet et réessayez"
    exit 1
fi

# Importer le script SQL
mysql -u root -proot < temp_download/Prospectius.sql 2>/dev/null || {
    echo "⚠️  Importation échouée avec l'utilisateur root:root"
    echo ""
    echo "Vérifiez que MariaDB est bien en cours d'exécution et que:"
    echo "  - L'utilisateur root existe"
    echo "  - Le mot de passe est 'root'"
    echo ""
    echo "Vous pouvez réessayer manuellement avec:"
    echo "  mysql -u root -proot < temp_download/Prospectius.sql"
    exit 1
}

echo "✓ Base de données configurée"
echo ""

echo "================================"
echo "✓ Installation terminée!"
echo "================================"
echo ""
echo "Fichiers téléchargés:"
echo "  Exécutable: temp_download/prospectius"
echo "  Dossier de téléchargement: temp_download/"
echo ""
echo "Prochaines étapes:"
echo ""
echo "1. Lancez l'application:"
echo "   ./temp_download/prospectius"
echo ""
echo "2. À la première exécution, configurez la base de données:"
echo "   Host: localhost"
echo "   Port: 3306"
echo "   User: root"
echo "   Password: root"
echo "   Database: Prospectius"
echo ""
echo "3. Créez votre compte:"
echo "   Cliquez sur 'S'inscrire' pour créer un nouveau compte"
echo "   Remplissez le formulaire avec vos informations"
echo ""
