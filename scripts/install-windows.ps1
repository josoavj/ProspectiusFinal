#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script d'installation de Prospectius pour Windows (PowerShell)
.DESCRIPTION
    Configure l'environnement complet pour Prospectius:
    - Télécharge prospectius.exe et Prospectius.sql depuis la latest release GitHub
    - Vérifie MariaDB/MySQL
    - Importe la schéma de base de données
.AUTHOR
    Prospectius Team
#>

$ErrorActionPreference = "Stop"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Installation de Prospectius" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Télécharger les fichiers depuis la latest release GitHub
Write-Host "Téléchargement des fichiers depuis GitHub..." -ForegroundColor Yellow

try {
    # Récupérer les informations de la latest release
    $releaseUrl = "https://api.github.com/repos/josoavj/ProspectiusFinal/releases/latest"
    $release = Invoke-WebRequest -Uri $releaseUrl -UseBasicParsing | ConvertFrom-Json
    
    # Créer le dossier de destination si nécessaire
    $downloadDir = Join-Path $PSScriptRoot "temp_download"
    if (-not (Test-Path $downloadDir)) {
        New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    }
    
    # Télécharger prospectius.exe
    $exeAsset = $release.assets | Where-Object { $_.name -eq "prospectius.exe" }
    if ($exeAsset) {
        $exePath = Join-Path $downloadDir "prospectius.exe"
        Write-Host "  Téléchargement de prospectius.exe..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $exeAsset.browser_download_url -OutFile $exePath -UseBasicParsing
        Write-Host "  ✓ prospectius.exe téléchargé" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ prospectius.exe non trouvé dans la release" -ForegroundColor Yellow
    }
    
    # Télécharger Prospectius.sql
    $sqlAsset = $release.assets | Where-Object { $_.name -eq "Prospectius.sql" }
    if ($sqlAsset) {
        $sqlPath = Join-Path $downloadDir "Prospectius.sql"
        Write-Host "  Téléchargement de Prospectius.sql..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $sqlAsset.browser_download_url -OutFile $sqlPath -UseBasicParsing
        Write-Host "  ✓ Prospectius.sql téléchargé" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Prospectius.sql non trouvé dans la release" -ForegroundColor Yellow
    }
    
    Write-Host "✓ Fichiers téléchargés avec succès" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur lors du téléchargement: $_" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

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

# Vérifier le script SQL téléchargé
Write-Host "Configuration de la base de données..." -ForegroundColor Yellow

$sqlScript = Join-Path $downloadDir "Prospectius.sql"
if (-not (Test-Path $sqlScript)) {
    Write-Host ""
    Write-Host "⚠ Attention: Script SQL n'a pas pu être téléchargé: $sqlScript" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifiez votre connexion Internet et réessayez" -ForegroundColor Yellow
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

# Fichiers téléchargés
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ Installation terminée!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Fichiers téléchargés:" -ForegroundColor Cyan
Write-Host "  Exécutable: $exePath" -ForegroundColor Yellow
Write-Host "  Dossier de téléchargement: $downloadDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Lancer l'application en double-cliquant sur:" -ForegroundColor Yellow
Write-Host "   $exePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. À la première exécution, configurez la base de données:" -ForegroundColor Yellow
Write-Host "   Host: localhost" -ForegroundColor Cyan
Write-Host "   Port: 3306" -ForegroundColor Cyan
Write-Host "   Utilisateur: root" -ForegroundColor Cyan
Write-Host "   Mot de passe: root" -ForegroundColor Cyan
Write-Host "   Base de données: Prospectius" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Créez votre compte:" -ForegroundColor Yellow
Write-Host "   Cliquez sur 'S'inscrire' pour créer un nouveau compte" -ForegroundColor Cyan
Write-Host "   Remplissez le formulaire avec vos informations" -ForegroundColor Cyan
Write-Host ""

Read-Host "Appuyez sur Entrée pour quitter"
