#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script d'installation de Prospectius pour Windows (PowerShell)
.DESCRIPTION
    Configure l'environnement complet pour Prospectius:
    - Vérifie MariaDB/MySQL
    - Importe la schéma de base de données
    - Installe les dépendances Flutter
.AUTHOR
    Prospectius Team
#>

$ErrorActionPreference = "Stop"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Installation de Prospectius" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier MariaDB/MySQL
Write-Host "Vérification de MariaDB/MySQL..." -ForegroundColor Yellow

$mysqlProcess = Get-Process mysqld -ErrorAction SilentlyContinue
if (-not $mysqlProcess) {
    Write-Host ""
    Write-Host "⚠ Attention: MySQL/MariaDB n'est pas détecté" -ForegroundColor Red
    Write-Host ""
    Write-Host "Assurez-vous que MariaDB est installé et démarré:" -ForegroundColor Yellow
    Write-Host "  https://mariadb.org/download/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Vous pouvez démarrer MariaDB de plusieurs façons:" -ForegroundColor Yellow
    Write-Host "  1. Services Windows (services.msc -> MariaDB)" -ForegroundColor Cyan
    Write-Host "  2. PowerShell (admin): Start-Service MariaDB" -ForegroundColor Cyan
    Write-Host "  3. Ou via l'installateur MariaDB" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "✓ MariaDB détecté" -ForegroundColor Green
Write-Host ""

# Vérifier Flutter
Write-Host "Vérification de Flutter..." -ForegroundColor Yellow

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host ""
    Write-Host "⚠ Attention: Flutter n'est pas installé" -ForegroundColor Red
    Write-Host ""
    Write-Host "Téléchargez et installez Flutter:" -ForegroundColor Yellow
    Write-Host "  https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Assurez-vous d'ajouter Flutter au PATH" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "✓ Flutter détecté ($(flutter --version))" -ForegroundColor Green
Write-Host ""

# Vérifier le script SQL
Write-Host "Configuration de la base de données..." -ForegroundColor Yellow

$sqlScript = "scripts\prospectius.sql"
if (-not (Test-Path $sqlScript)) {
    Write-Host ""
    Write-Host "⚠ Attention: Script SQL non trouvé: $sqlScript" -ForegroundColor Red
    Write-Host ""
    Write-Host "Téléchargez le script depuis:" -ForegroundColor Yellow
    Write-Host "  https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Et placez-le dans: $sqlScript" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "✓ Script SQL trouvé" -ForegroundColor Green

# Importer le script SQL
Write-Host "Importation du schéma de base de données..." -ForegroundColor Yellow

try {
    # Vérifier la connexion MySQL d'abord
    $testConnection = mysql -u root -proot -e "SELECT 1" 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠ Impossible de se connecter à MySQL" -ForegroundColor Red
        Write-Host "Vérifiez que:" -ForegroundColor Yellow
        Write-Host "  - MariaDB est bien en cours d'exécution" -ForegroundColor Cyan
        Write-Host "  - L'utilisateur root existe avec le mot de passe 'root'" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
    
    # Importer le script
    Get-Content $sqlScript | mysql -u root -proot
    Write-Host "✓ Base de données configurée" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur lors de l'importation: $_" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host ""

# Récupérer les dépendances Flutter
Write-Host "Récupération des dépendances Flutter..." -ForegroundColor Yellow

try {
    flutter pub get
    Write-Host "✓ Dépendances installées" -ForegroundColor Green
}
catch {
    Write-Host "⚠ Attention lors de la récupération des dépendances: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ Installation terminée!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Lancer l'application:" -ForegroundColor Yellow
Write-Host "   flutter run -d windows" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. À la première exécution, configurez la base de données:" -ForegroundColor Yellow
Write-Host "   Host: localhost" -ForegroundColor Cyan
Write-Host "   Port: 3306" -ForegroundColor Cyan
Write-Host "   Utilisateur: root" -ForegroundColor Cyan
Write-Host "   Mot de passe: root" -ForegroundColor Cyan
Write-Host "   Base de données: Prospectius" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Connectez-vous avec les identifiants par défaut:" -ForegroundColor Yellow
Write-Host "   Utilisateur: admin" -ForegroundColor Cyan
Write-Host "   Mot de passe: admin" -ForegroundColor Cyan
Write-Host ""

Read-Host "Appuyez sur Entrée pour quitter"
