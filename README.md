
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
- **Suivi des interactions:** Enregistrement des appels, emails, réunions avec chaque prospect
- **Gestion des clients:** Conversion des prospects en clients
- **Statistiques et reporting:** Tableaux de bord et graphiques de conversion
- **Support multi-plateforme:** Windows et Linux

## ⚡ Installation Rapide

### Toutes les Plateformes

```bash
bash scripts/setup.sh
```

Ce script détecte votre OS et lance l'installation appropriée.

### Ou Manuellement

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

### Windows
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) avec les outils de développement C++
- [MariaDB](https://mariadb.org/download/) ou [MySQL](https://dev.mysql.com/downloads/mysql/)
- Git

### Linux (Ubuntu/Debian)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- Build essentials: `sudo apt install build-essential cmake git libgtk-3-dev pkg-config libssl-dev`
- [MariaDB Server](https://mariadb.org/download/#mariadb_repositories): `sudo apt install mariadb-server`
- Git

## 🔧 Installation et Configuration

### 1. Installation de MariaDB

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

### 2. Créer la base de données

```bash
# Cloner le repo du backend
git clone https://github.com/josoavj/dbProspectius.git

# Importer le schéma
mysql -u root -p < dbProspectius/scriptSQL/Prospectius.sql
```

Ou manuellement:
```bash
mysql -u root -p
# Dans le client MySQL:
SOURCE /chemin/vers/Prospectius.sql;
EXIT;
```

### 3. Cloner et configurer Prospectius

```bash
git clone <repository-url>
cd prospectius

flutter pub get
flutter config --enable-windows-desktop  # Pour Windows
flutter config --enable-linux-desktop    # Pour Linux
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
│   ├── widgets/           # Widgets réutilisables
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

## 📖 Documentation Complète

Voir [INSTALLATION.md](INSTALLATION.md) pour des instructions détaillées.

## 👥 Équipe contributeur

- **Développeur:** [josoavj](https://github.com/josoavj)

## 📝 Notice

- N'oubliez pas d'installer toutes les dépendances requises pour le projet. Elles sont dans [pubspec.yaml](pubspec.yaml)
- N'oubliez pas de créer la base de données [Prospectius](https://github.com/josoavj/dbProspectius) sur votre machine ou serveur
- Vérifier les paramètres de connexion à la base de données lors du premier lancement
- Assurez-vous que MariaDB/MySQL est en cours d'exécution avant de lancer l'application
