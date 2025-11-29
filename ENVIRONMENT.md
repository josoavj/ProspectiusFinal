# Configuration d'Environnement - Prospectius

Ce fichier documente les variables d'environnement et configurations pour Prospectius.

## Configuration MariaDB

### Paramètres Par Défaut

```
Host: localhost
Port: 3306
User: root
Password: root
Database: Prospectius
```

### Variables d'Environnement (Optionnel)

Vous pouvez définir ces variables pour surcharger les paramètres par défaut:

**Linux/macOS:**
```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=root
export DB_NAME=Prospectius
```

**Windows (PowerShell):**
```powershell
$env:DB_HOST = "localhost"
$env:DB_PORT = "3306"
$env:DB_USER = "root"
$env:DB_PASSWORD = "root"
$env:DB_NAME = "Prospectius"
```

**Windows (CMD):**
```cmd
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=root
set DB_NAME=Prospectius
```

## Configuration Flutter

### Plateformes Activées

```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop  # Optionnel
```

### Build Targets

```bash
# Windows
flutter run -d windows
flutter build windows --release

# Linux
flutter run -d linux
flutter build linux --release

# macOS
flutter run
flutter build macos --release
```

## Dépendances Principales

```yaml
dependencies:
  provider: ^6.0.0
  mysql1: ^0.20.0
  shared_preferences: ^2.2.0
  crypto: ^3.0.0
  csv: ^6.0.0
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## Comptes d'Accès Par Défaut

Après importation du script Prospectius.sql:

### Admin
```
Username: admin
Password: admin
Type: ADMIN
```

### Standard User (si créé)
```
Username: user
Password: user123
Type: USER
```

## Chemins Importants

### Linux
```
SharedPreferences: ~/.local/share/prospectius/
Logs: ~/.config/prospectius/logs/
```

### macOS
```
SharedPreferences: ~/Library/Application Support/prospectius/
Logs: ~/Library/Logs/prospectius/
```

### Windows
```
SharedPreferences: %APPDATA%\prospectius\
Logs: %APPDATA%\prospectius\logs\
```

## Structure des Tables

### account
```sql
CREATE TABLE account (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  typeCompte ENUM('ADMIN', 'USER'),
  dateCreation DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### prospect
```sql
CREATE TABLE prospect (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idCompte INT NOT NULL,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100),
  email VARCHAR(100),
  telephone VARCHAR(20),
  entreprise VARCHAR(100),
  statut ENUM('NOUVEAU', 'EN_COURS', 'QUALIFIE', 'CONVERTI', 'PERDU'),
  source VARCHAR(100),
  notes TEXT,
  dateAjout DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idCompte) REFERENCES account(id)
);
```

### interaction
```sql
CREATE TABLE interaction (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idProspect INT NOT NULL,
  type VARCHAR(50),
  description TEXT,
  dateInteraction DATETIME,
  FOREIGN KEY (idProspect) REFERENCES prospect(id) ON DELETE CASCADE
);
```

## Performances et Limits

- Max prospects par compte: Non limité
- Max interactions par prospect: Non limité
- Taille max des notes: 65535 caractères
- Pool de connexions: 5 par défaut

## Sécurité

### Recommandations

1. **Mot de passe root MySQL**
   - Changez le mot de passe par défaut après installation
   ```bash
   mysqladmin -u root -proot password
   ```

2. **Compte utilisateur**
   - Créez un utilisateur MySQL dédié (au lieu d'utiliser root)
   ```sql
   CREATE USER 'prospectius'@'localhost' IDENTIFIED BY 'secure_password';
   GRANT ALL PRIVILEGES ON Prospectius.* TO 'prospectius'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Base de données**
   - Toujours sauvegarder la base de données
   ```bash
   mysqldump -u root -proot Prospectius > backup.sql
   ```

## Logs et Diagnostic

### Activer les logs détaillés
```bash
flutter run -v
```

### Logs MariaDB
**Linux:**
```bash
sudo tail -f /var/log/mysql/error.log
```

**macOS:**
```bash
tail -f /usr/local/var/mysql/$(hostname).err
```

**Windows:**
```
C:\Program Files\MariaDB Foundation\MariaDB\data\*.err
```

## Support et Ressources

- **Documentation Flutter:** https://flutter.dev/docs
- **Documentation MariaDB:** https://mariadb.com/kb/
- **Repository Prospectius:** https://github.com/josoavj/prospectius
- **Repository Backend:** https://github.com/josoavj/dbProspectius
