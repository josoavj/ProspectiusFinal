# Guide d'Installation - Prospectius

Ce guide vous aidera à configurer et lancer Prospectius sur votre système.

---

## 🎯 Choisissez votre installation:

### 👤 Utilisateurs Finaux

Vous voulez simplement utiliser l'application sans modifications.

### 👨‍💻 Développeurs

Vous voulez modifier le code et compiler votre propre version.

---

## Installation Rapide (Utilisateurs Finaux)

### Option 1: Exécutables Préconfigurés (Recommandé)

**1. Téléchargez les fichiers:**

- Rendez-vous sur la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest)
- Téléchargez:
  - `prospectius.exe` (Windows) ou `prospectius` (Linux)
  - `Prospectius.sql`

**2. Installez MariaDB:**

**Linux (Debian/Ubuntu):**

```bash
sudo apt update
sudo apt install mariadb-server
sudo systemctl start mariadb
```

**Linux (Fedora/RHEL):**

```bash
sudo dnf install mariadb-server
sudo systemctl start mariadb
```

**Windows:**

- Téléchargez depuis https://mariadb.org/download/
- Installez avec les paramètres par défaut

**3. Importez la base de données:**

```bash
mysql -u root -proot < Prospectius.sql
```

**4. Lancez l'application:**

- **Windows:** Double-cliquez sur `prospectius.exe`
- **Linux:** `./prospectius`

### Option 2: Scripts d'Installation Automatiques

Les scripts téléchargeront automatiquement l'exécutable et configureront la base de données.

**Linux:**

```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
bash scripts/install-linux.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

**Windows (CMD):**

```cmd
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
scripts\install-windows.bat
```

---

## Installation pour Développeurs

### Installation Complète (Toutes Plateformes)

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

**Windows (CMD):**

```cmd
scripts\install-windows.bat
```

---

## Configuration Initiale (Pour Développeurs)

### 1. Cloner le projet

```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
flutter pub get
```

### 2. Démarrer MariaDB

**Linux (Debian/Ubuntu):**

```bash
sudo systemctl start mariadb
```

**Linux (Fedora/RHEL):**

```bash
sudo systemctl start mariadb
```

**macOS:**

```bash
brew services start mariadb
```

**Windows:**

- Via Services: Services.msc → Chercher "MariaDB" → Démarrer
- Via PowerShell (admin): `Start-Service MariaDB`
- Via Homebrew: `brew services start mariadb`

### 3. Importer la Base de Données

Téléchargez le script SQL:

```bash
bash scripts/download-sql.sh
```

Puis importez-le:

```bash
mysql -u root -proot < scripts/Prospectius.sql
```

### 4. Lancer l'Application en Développement

```bash
flutter run -d windows     # Windows
flutter run -d linux       # Linux
flutter run                # macOS
```

### 5. Première Connexion

À la première exécution, configurez la connexion:

**Paramètres par défaut:**

- **Host:** localhost
- **Port:** 3306
- **User:** root
- **Password:** root
- **Database:** Prospectius

**Créer un compte:**

- Cliquez sur "S'inscrire"
- Remplissez le formulaire
- Vous pourrez alors vous connecter

---

## Dépannage

### MariaDB non détecté

- Vérifiez que MariaDB est bien installé
- Vérifiez que le service MariaDB est démarré
- Assurez-vous que `mysql` est dans le PATH

### Erreur de connexion MySQL

```bash
# Testez la connexion
mysql -u root -proot -e "SELECT 1"

# Si erreur "Access denied":
# Réinitialisez le mot de passe MySQL
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');"
```

### Flutter non trouvé (Développeurs uniquement)

Assurez-vous que Flutter est installé et dans le PATH:

```bash
flutter --version
which flutter  # Linux/macOS
```

### Script SQL non trouvé

Téléchargez le script depuis la release ou le dépôt:

```bash
bash scripts/download-sql.sh
```

Ou directement depuis la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest)

---

## Structure des Scripts

| Script | Plateforme | Description |
|--------|-----------|-------------|
| `setup.sh` | Toutes | Détecte la plateforme et lance le bon script |
| `install-linux.sh` | Linux | Configuration pour Linux (Ubuntu/Debian/Fedora/Arch) |
| `install-macos.sh` | macOS | Configuration pour macOS (avec Homebrew) |
| `install-windows.ps1` | Windows | Configuration pour Windows (PowerShell) |
| `install-windows.bat` | Windows | Configuration pour Windows (CMD) |

---

## Configuration Avancée (Développeurs)

### Changer les Paramètres MySQL

Les paramètres par défaut sont:

- **Host:** localhost
- **Port:** 3306
- **User:** root
- **Password:** root

Pour changer, lancez l'application et modifiez dans la première page de configuration.

### Les paramètres sont locaux

Les paramètres MySQL sont stockés localement (SharedPreferences) et peuvent être modifiés une seule fois à la première connexion.

Pour réinitialiser les paramètres:

```bash
# Linux/macOS
rm -rf ~/.local/share/prospectius  # ou le dossier de config approprié

# Windows
# Supprimez le dossier %APPDATA%\prospectius (si existant)
```

---

## Support

Pour plus d'informations:

- **Documentation Flutter:** https://flutter.dev
- **Documentation MariaDB:** https://mariadb.org
- **Repository GitHub:** https://github.com/josoavj/ProspectiusFinal
- **Releases:** https://github.com/josoavj/ProspectiusFinal/releases

---

## Licence

Ce projet utilise les dépendances suivantes:

- **provider:** ^6.0.0
- **mysql1:** ^0.20.0
- **shared_preferences:** ^2.2.0
- **crypto:** ^3.0.0
- **csv:** ^6.0.0
