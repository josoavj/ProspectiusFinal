# Guide d'Installation - Prospectius

Ce guide vous aidera à configurer et lancer Prospectius sur votre système.

## Installation Rapide

### Linux
```bash
bash scripts/install-linux.sh
```

### macOS
```bash
bash scripts/install-macos.sh
```

### Windows
Via PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

Via CMD:
```cmd
scripts\install-windows.bat
```

### Installation Automatique (Toutes Plateformes)
```bash
bash scripts/setup.sh
```

---

## Configuration Initiale

### 1. Démarrer MariaDB

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

### 2. Importer la Base de Données

Téléchargez d'abord le script SQL:
```bash
curl -o scripts/prospectius.sql https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql
```

Puis importez-le:
```bash
mysql -u root -proot < scripts/prospectius.sql
```

### 3. Lancer l'Application

```bash
flutter run -d windows     # Windows
flutter run -d linux       # Linux
flutter run                # macOS
```

### 4. Première Connexion

À la première exécution, configurez la connexion:

**Paramètres par défaut:**
- **Host:** localhost
- **Port:** 3306
- **User:** root
- **Password:** root
- **Database:** Prospectius

**Connexion par défaut:**
- **Utilisateur:** admin
- **Mot de passe:** admin

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

### Flutter non trouvé
Assurez-vous que Flutter est installé et dans le PATH:
```bash
flutter --version
which flutter  # Linux/macOS
```

### Script SQL non trouvé
Téléchargez le script depuis le dépôt dbProspectius:
https://github.com/josoavj/dbProspectius/tree/master/scriptSQL

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

## Configuration Avancée

### Changer les Paramètres MySQL

Les paramètres par défaut sont:
- **Host:** localhost
- **Port:** 3306
- **User:** root
- **Password:** root

Pour changer, lancez l'application et modifiez dans la première page de configuration.

### Désactiver MariaDB
Les paramètres MySQL sont stockés localement (SharedPreferences) et ne peuvent pas être modifiés une fois la première connexion établie.

Pour réinitialiser:
```bash
# Linux/macOS - supprimer la config (dans l'appli: supprimer le dossier config)
# Windows - supprimer le dossier %APPDATA%\Prospectius (si existant)
```

---

## Prochaines Étapes

Après l'installation réussie:

1. **Lancer l'app:** `flutter run`
2. **Se connecter:** admin/admin
3. **Explorer:** Accédez à l'interface Prospects
4. **Importer des données:** Via le formulaire d'ajout de prospect
5. **Consulter les stats:** Allez à l'onglet Statistiques

---

## Support

Pour plus d'informations:
- **Flutter:** https://flutter.dev
- **MariaDB:** https://mariadb.org
- **Repository:** https://github.com/josoavj/dbProspectius

---

## Licence

Ce projet utilise les dépendances suivantes:
- **provider:** ^6.0.0
- **mysql1:** ^0.20.0
- **shared_preferences:** ^2.2.0
- **crypto:** ^3.0.0
- **csv:** ^6.0.0
