# Prospectius

Une application CRM Flutter pour Windows utilisant MySQL en local.

## Prérequis

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) avec les outils de développement C++
- [MySQL/MariaDB](https://dev.mysql.com/downloads/mysql/) ou [MariaDB](https://mariadb.org/download/)
- Git

## Installation et Configuration

### 1. Installation de MySQL/MariaDB

#### Option A: Installation locale sur Windows

1. Télécharger et installer [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) ou [MariaDB](https://mariadb.org/download/)
2. Configurer le serveur avec:
   - Host: `localhost`
   - Port: `3306` (défaut)
   - User: `root`
   - Password: `root` (ou votre mot de passe)

#### Option B: Utiliser Docker (optionnel)

```bash
docker run -d \
  --name prospectius-db \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=Prospectius \
  -e MYSQL_USER=prospectius_user \
  -e MYSQL_PASSWORD=prospectius_password \
  -p 3306:3306 \
  mariadb:latest
```

### 2. Créer la base de données

Exécuter le script SQL depuis le dépôt backend:
```bash
# Télécharger le script du backend
git clone https://github.com/josoavj/dbProspectius.git
cd dbProspectius

# Importer le script dans MySQL
mysql -u root -p < scriptSQL/Prospectius.sql
```

Ou manuellement:
```bash
mysql -u root -p
# Dans le client MySQL:
SOURCE /chemin/vers/Prospectius.sql;
```

### 3. Configurer et Lancer Prospectius

```bash
# Cloner le projet
git clone <repository-url>
cd prospectius

# Récupérer les dépendances Flutter
flutter pub get

# Activer le support Windows Desktop
flutter config --enable-windows-desktop
```

## Lancement de l'application

### Mode Debug

```bash
flutter run -d windows
```

### Mode Release

```bash
flutter run -d windows --release
```

## Configuration de la Base de Données

Au premier lancement, l'application affiche l'écran de configuration:

- **Hôte**: `localhost` (ou votre serveur MySQL)
- **Port**: `3306` (défaut MySQL)
- **Utilisateur**: `root`
- **Mot de passe**: votre mot de passe MySQL
- **Base de données**: `Prospectius`

La configuration est sauvegardée pour les prochains lancements.

## Build Release

Créer une version Windows Release:

```bash
flutter build windows --release
```

L'exécutable sera disponible à:
```
build/windows/x64/runner/Release/prospectius.exe
```

## Fonctionnalités

- ✅ Authentification avec MySQL
- ✅ Gestion des prospects (CRUD)
- ✅ Suivi des interactions
- ✅ Statistiques et reporting
- ✅ Export de données

## Structure du projet

```
prospectius/
├── lib/
│   ├── main.dart              # Point d'entrée
│   ├── models/                # Modèles de données
│   ├── services/              # Services (MySQL, Storage)
│   ├── providers/             # Gestion d'état (Provider)
│   ├── screens/               # Écrans de l'application
│   └── widgets/               # Widgets réutilisables
├── windows/                   # Configuration Windows
├── .github/workflows/         # GitHub Actions CI/CD
├── pubspec.yaml              # Dépendances
└── README.md                 # Ce fichier
```

## Troubleshooting

### "MySQL non connecté"
- Vérifiez que le serveur MySQL est en cours d'exécution
- Vérifiez les paramètres de connexion dans l'écran de configuration

### "Base de données non trouvée"
- Vérifiez que le script `Prospectius.sql` a été exécuté
- Vérifiez que le nom de la base de données est correct

### Problèmes de package Flutter
```bash
flutter clean
flutter pub get
```

## License

Tous droits réservés.
