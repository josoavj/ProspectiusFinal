
<h1 align="center">Prospectius</h1>

<p align="center">
  <strong>Application CRM pour la gestion des prospects et de leurs interactions</strong>
</p>

<p align="center">
  <!--Badges -->
  <img src="https://img.shields.io/badge/license-All%20Rights%20Reserved-red" alt="License">
  <img src="https://img.shields.io/badge/flutter-v3.35.6-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/dart-v3.9.2-blue" alt="Dart">
  <img src="https://img.shields.io/badge/database-MySQL-orange" alt="Database">
  <img src="https://img.shields.io/github/last-commit/josoavj/ProspectiusFinal?style=flat-square" alt="Last Commit">
</p>

## 📖 À propos

- **Framework:** Flutter
- **Langage:** Dart (Version 3.9.2 +)
- **Gestion d'état:** Provider 6.0.0
- **Base de données:** MySQL / MariaDB
- **Schéma SQL:** [Base de données Prospectius](https://github.com/josoavj/dbProspectius)

## ✨ Fonctionnalités

- **Authentification:** Connexion sécurisée avec MariaDB/MySQL
- **Gestion des prospects:** Création, lecture, mise à jour et suppression de prospects
- **Exploration avancée:** Recherche multi-critères, filtrage par catégorie et dates, tri personnalisé
- **Suivi des interactions:** Enregistrement des appels, emails, réunions avec chaque prospect
- **Gestion des clients:** Conversion des prospects en clients
- **Statistiques et reporting:** Tableaux de bord et graphiques de conversion
- **Support multi-plateforme:** Windows et Linux

## ⚡ Installation Rapide

### 👤 Pour les Utilisateurs Finaux

**Option 1: Exécutables Préconfigurés (Recommandé)**

1. Téléchargez les fichiers depuis la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest)
   - `prospectius.exe` (Windows) ou `prospectius` (Linux)
   - `Prospectius.sql`

2. Installez MariaDB:
   - Windows: https://mariadb.org/download/
   - Linux: `sudo apt install mariadb-server`

3. Importez la base de données:
   ```bash
   mysql -u root -proot < Prospectius.sql
   ```

4. Lancez l'application:
   - Windows: Double-cliquez sur `prospectius.exe`
   - Linux: `./prospectius`

**Option 2: Scripts d'Installation Automatiques**

```bash
# Linux
bash scripts/install-linux.sh

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

### 👨‍💻 Pour les Développeurs (Développement & Modifications)

```bash
bash scripts/setup.sh
```

Ce script détecte votre OS et lance l'installation appropriée.

**Ou manuellement:**

**Linux:**
```bash
bash scripts/install-linux.sh
```

**macOS:**
```bash
bash scripts/install-macos.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

## 📋 Prérequis

### Pour les Utilisateurs Finaux

- **MariaDB 10.3+** ou **MySQL 5.7+**
- **Windows 8.1+** (64-bit) OU **Linux Ubuntu 18.04+** (64-bit)

### Pour les Développeurs

**Windows**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Dart 3.0.0+](https://dart.dev/get-dart) (inclus dans Flutter)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) avec les outils de développement C++
- [MariaDB](https://mariadb.org/download/) ou [MySQL](https://dev.mysql.com/downloads/mysql/)
- Git

**Linux (Ubuntu/Debian)**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Dart 3.0.0+](https://dart.dev/get-dart) (inclus dans Flutter)
- Build essentials: `sudo apt install build-essential cmake git libgtk-3-dev pkg-config libssl-dev`
- [MariaDB Server](https://mariadb.org/download/#mariadb_repositories): `sudo apt install mariadb-server`
- Git

**macOS**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Dart 3.0.0+](https://dart.dev/get-dart) (inclus dans Flutter)
- [Xcode](https://apps.apple.com/us/app/xcode/id497799835)
- [MariaDB](https://mariadb.org/download/) ou MySQL
- Git

## 🔧 Installation et Configuration (Pour Développeurs)

### 1. Cloner et configurer le projet

```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal

flutter pub get
flutter config --enable-windows-desktop  # Pour Windows
flutter config --enable-linux-desktop    # Pour Linux
```

### 2. Installation de MariaDB

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install mariadb-server
sudo mariadb-secure-installation

# Démarrer le service
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

#### Windows
1. Télécharger depuis [mariadb.org](https://mariadb.org/download/)
2. Installer avec les paramètres par défaut
3. MariaDB sera accessible sur `localhost:3306`

### 3. Créer la base de données

```bash
# Télécharger le schéma
bash scripts/download-sql.sh

# Importer la base
mysql -u root -proot < scripts/Prospectius.sql
```

Ou manuellement:
```bash
mysql -u root -p
# Dans le client MySQL:
SOURCE /chemin/vers/Prospectius.sql;
EXIT;
```

## 🚀 Lancement de l'application

### Windows
```bash
## Mode debug
flutter run -d windows

## Mode release

flutter build windows --release
```

L'exécutable sera à: `build/windows/x64/runner/Release/prospectius.exe`

### Linux
```bash
# Mode debug
flutter run -d linux

# Mode release
flutter build linux --release
```

L'exécutable sera à: `build/linux/x64/release/prospectius`

## 🗄️ Configuration de la Base de Données

Au premier lancement, configurez la connexion:
- **Hôte**: `localhost`
- **Port**: `3306`
- **Utilisateur**: `root` (ou votre utilisateur)
- **Mot de passe**: votre mot de passe MariaDB
- **Base de données**: `Prospectius`

## 📁 Structure du projet

```
prospectius/
├── lib/                    # Code source Dart/Flutter
│   ├── main.dart          # Point d'entrée
│   ├── models/            # Modèles de données
│   ├── services/          # Services (MySQL, Storage)
│   ├── providers/         # Gestion d'état
│   ├── screens/           # Écrans de l'application
│   │   ├── exploration_screen.dart     # Recherche et filtrage avancés
│   │   ├── prospects_screen.dart       # Gestion des prospects
│   │   ├── stats_screen.dart          # Statistiques
│   │   ├── clients_screen.dart        # Gestion des clients
│   │   ├── export_prospects_screen.dart # Export données
│   │   ├── profile_screen.dart        # Profil utilisateur
│   │   ├── login_screen.dart          # Authentification
│   │   ├── register_screen.dart       # Inscription
│   │   ├── configuration_screen.dart  # Paramètres
│   │   ├── database_config_screen.dart # Config BD
│   │   ├── about_screen.dart          # À propos
│   │   ├── add_prospect_screen.dart   # Ajouter prospect
│   │   ├── edit_prospect_screen.dart  # Modifier prospect
│   │   └── prospect_detail_screen.dart # Détails prospect
│   ├── widgets/           # Widgets réutilisables
│   │   └── sidebar_navigation.dart    # Menu latéral
│   └── utils/             # Utilitaires
├── windows/               # Configuration Windows (C++)
├── linux/                 # Configuration Linux (C++)
├── test/                  # Tests
├── .github/workflows/     # CI/CD
├── pubspec.yaml          # Dépendances
└── README.md             # Ce fichier
```

## 🐛 Troubleshooting

### "MariaDB non connecté"

```bash
# Vérifier le statut
sudo systemctl status mariadb  # Linux
mysql.server status            # macOS
# Windows: Services.msc → MariaDB

# Redémarrer
sudo systemctl restart mariadb  # Linux
brew services restart mariadb   # macOS
```

### "Base de données non trouvée"

```bash
mysql -u root -p -e "SHOW DATABASES;"
```

### Problèmes de build
```bash
flutter clean
flutter pub get
flutter run -v
```

## 📚 Scripts Utiles

- `scripts/setup.sh` - Installation automatique (détecte l'OS)
- `scripts/install-linux.sh` - Installation sur Linux
- `scripts/install-macos.sh` - Installation sur macOS  
- `scripts/install-windows.ps1` - Installation sur Windows (PowerShell)
- `scripts/install-windows.bat` - Installation sur Windows (CMD)
- `scripts/download-sql.sh` - Télécharger le schéma SQL
- `scripts/validate.sh` - Valider l'installation

## 📚 Documentation Complète

Voir [INSTALLATION.md](INSTALLATION.md) pour des instructions détaillées.

### Pages et Fonctionnalités

#### 🔍 Exploration (Nouvelle Fonctionnalité)
- Recherche multi-critères en temps réel
- Filtrage par catégorie (Entreprise, Particulier, Startup, PME, ETI)
- Filtrage par plage de dates de création
- Options de tri (plus récents/anciens, alphabétique, par statut)
- Affichage détaillé des résultats avec contacts et informations

#### 👥 Gestion des Prospects
- Créer, modifier, consulter et supprimer des prospects
- Enregistrement des informations de contact
- Historique des interactions
- Affichage du statut (Nouveau, En cours, Qualifié, Converti, Perdu)

#### 📊 Statistiques
- Tableaux de bord avec les indicateurs clés
- Graphiques de conversion
- Suivi des performances

#### 💼 Gestion des Clients
- Liste des prospects convertis en clients
- Suivi des contrats
- Historique commercial

## 👥 Équipe contributeur

- **Développeur:** [josoavj](https://github.com/josoavj)

## 📝 Notice

- N'oubliez pas d'installer toutes les dépendances requises pour le projet. Elles sont dans [pubspec.yaml](pubspec.yaml)
- N'oubliez pas de créer la base de données [Prospectius](https://github.com/josoavj/dbProspectius) sur votre machine ou serveur
- Vérifier les paramètres de connexion à la base de données lors du premier lancement
- Assurez-vous que MariaDB/MySQL est en cours d'exécution avant de lancer l'application
