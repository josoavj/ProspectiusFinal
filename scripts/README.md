# Scripts d'Installation et Configuration - Prospectius

Ce répertoire contient tous les scripts d'automatisation pour configurer Prospectius sur les différentes plateformes.

## Vue d'ensemble

| Script | OS | Type | Description |
|--------|----|----|-------------|
| `setup.sh` | Toutes | Shell | **Recommandé** : détecte l'OS et lance l'installateur approprié |
| `install-linux.sh` | Linux | Shell | Configure Prospectius sur Linux (Ubuntu, Debian, Fedora, Arch) |
| `install-macos.sh` | macOS | Shell | Configure Prospectius sur macOS avec Homebrew |
| `install-windows.ps1` | Windows | PowerShell | Télécharge l'archive Windows complète et configure la base de données |
| `install-windows.bat` | Windows | Batch | Lance l'installation Windows PowerShell |
| `download-sql.sh` | Toutes | Shell | Télécharge le schéma SQL du dépôt ProspectiusFinal |
| `validate.sh` | Toutes | Shell | Valide l'installation et affiche un diagnostic |
| `clean.sh` | Toutes | Shell | Nettoie les caches et réinstalle les dépendances |

Les workflows publient plusieurs formats :

- Windows : `Prospectius_Setup_v<version>.exe` (installateur complet) et
  `prospectius-windows-x64.zip` (version portable).
- Linux : `prospectius_<version>_amd64.deb` (installation Debian/Ubuntu) et
  `prospectius-linux-x64.tar.gz` (version portable).

Le schéma est inclus dans les archives sous `Database/Prospectius.sql`.

Les paramètres de connexion peuvent être fournis par variables d’environnement :
`PROSPECTIUS_DB_USER`, `PROSPECTIUS_DB_PASSWORD`, `PROSPECTIUS_DB_HOST` et
`PROSPECTIUS_DB_PORT`. Le mot de passe n’est plus défini dans les scripts.

L’installateur Windows `.exe` ne télécharge pas MariaDB automatiquement. Il vérifie
si MariaDB/MySQL est présent et propose d’ouvrir la page officielle de MariaDB s’il
est absent. S’il est présent, l’installateur demande l’hôte, le port, l’utilisateur
et le mot de passe, puis importe automatiquement `Database/Prospectius.sql` uniquement
si la base `Prospectius` n’existe pas encore. Le fichier `Database/SuppressionDB.sql`
est livré comme outil manuel et n’est jamais exécuté automatiquement.

---

## Démarrage rapide

### Option 1: Installation Automatique (Recommandé)

```bash
bash setup.sh
```

Ce script détecte automatiquement votre OS et exécute le bon installateur.

**Windows:** Vous pouvez aussi directement utiliser les fichiers téléchargés depuis la [latest release](https://github.com/josoavj/ProspectiusFinal/releases/latest) :

- Extrayez `prospectius-windows-x64.zip`, puis lancez `prospectius.exe`
- Lancez `install-windows.ps1` ou `install-windows.bat` pour configurer la base de données

### Option 2: Installation Manuelle

**Linux:**

```bash
bash install-linux.sh
```

**macOS:**

```bash
bash install-macos.sh
```

**Windows (PowerShell - Recommandé):**

```powershell
powershell -ExecutionPolicy Bypass -File install-windows.ps1
```

**Windows (CMD):**

```cmd
install-windows.bat
```

**Windows (Direct depuis la release):**

1. Téléchargez les fichiers depuis la [latest release](https://github.com/josoavj/ProspectiusFinal/releases/latest)
2. Installez MariaDB
3. Double-cliquez sur `prospectius.exe`

---

## Description détaillée

### setup.sh
**Rôle:** Script maître de détection automatique

```bash
bash setup.sh
```

- ✅ Détecte le système d'exploitation
- ✅ Lance le script d'installation approprié
- ✅ Affiche les instructions de démarrage après installation

### install-linux.sh
**Rôle:** Configuration complète pour Linux

```bash
bash install-linux.sh
```

**Fonctionnalités:**

- Détecte la distribution Linux (Ubuntu/Debian, Fedora/RHEL, Arch)
- Installe les dépendances système requises
- Installe et configure MariaDB
- Importe le schéma de base de données
- Récupère les dépendances Flutter
- Affiche les instructions de lancement

**Distributions Supportées:**

- Ubuntu / Debian
- Fedora / RHEL / CentOS
- Arch Linux

### install-macos.sh
**Rôle:** Configuration pour macOS

```bash
bash install-macos.sh
```

**Fonctionnalités:**

- Vérifie Homebrew (installe si nécessaire)
- Installe MariaDB via Homebrew
- Démarre le service MariaDB
- Importe le schéma de base de données
- Récupère les dépendances Flutter
- Affiche les instructions de lancement

### install-windows.ps1
**Rôle:** Configuration pour Windows via PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File install-windows.ps1
```

**Fonctionnalités:**

- Télécharge `prospectius-windows-x64.zip`, l'extrait et importe `Database/Prospectius.sql`
- Vérifie l'installation de MariaDB
- Teste la connexion MySQL
- Importe le schéma de base de données
- Lance l'application
- Affiche les instructions de configuration

**Avantages:**

- Plus moderne que CMD
- Meilleure gestion des erreurs
- Couleurs pour une meilleure lisibilité
- Téléchargement automatique des fichiers depuis la release
- Idéal pour une première installation

### install-windows.bat
**Rôle:** Configuration pour Windows via CMD

```cmd
install-windows.bat
```

**Fonctionnalités:**

- Télécharge `prospectius-windows-x64.zip`, l'extrait et importe `Database/Prospectius.sql`
- Vérifie l'installation de MariaDB
- Importe le schéma de base de données
- Lance l'application
- Affiche les instructions de configuration

**Avantages:**

- Compatible avec tous les systèmes Windows
- Pas de dépendances PowerShell
- Téléchargement automatique des fichiers depuis la release

### download-sql.sh
**Rôle:** Télécharge le schéma SQL

```bash
bash download-sql.sh
```

**Fonctionnalités:**

- Télécharge `scripts/Database/Prospectius.sql` depuis le dépôt ProspectiusFinal
- Utilise curl ou wget (auto-détection)
- Sauvegarde dans `scripts/Database/Prospectius.sql`

**Utilité:**

- Installation manuelle de la base de données
- Mise à jour du schéma
- Alternative aux scripts d'installation automatiques

### validate.sh
**Rôle:** Valide l'installation et affiche un diagnostic

```bash
bash validate.sh
```

**Vérifie:**

- ✅ Installation de Flutter
- ✅ Installation de MySQL/MariaDB
- ✅ Connectivité MySQL
- ✅ Existence de la base Prospectius
- ✅ Dépendances Flutter installées
- ✅ Structure du projet

**Affiche:**

- Version Flutter
- Configuration supportée
- Taille du cache Flutter
- Statistiques du projet
- État de la base de données

**Sortie:**

- ✅ Si tous les contrôles passent
- ❌ Erreurs détectées avec solutions

### clean.sh
**Rôle:** Nettoie les caches et réinstalle

```bash
bash clean.sh
```

**Nettoie:**

- Répertoire `build/`
- Fichier `pubspec.lock`
- Répertoire `.dart_tool`
- Cache Flutter (rapport uniquement)

**Réinstalle:**

- Dépendances Flutter (`flutter pub get`)

**Affiche:**

- Diagnostic complet après nettoyage
- Versions de Flutter et dépendances
- État de la base de données
- Recommandations

---

## ⚙️ Configuration Requise

### Avant de lancer les scripts

1. **Cloner le projet:**

   ```bash
   git clone <repository-url>
   cd prospectius
   ```

2. **Permissions (Linux/macOS):**
   - Les scripts shell sont déjà exécutables
   - Sur Windows, PowerShell doit autoriser l'exécution

3. **SQL Script:**
   - Les scripts Windows extraient `Database/Prospectius.sql` depuis l'archive de release
   - Pour Linux/macOS, utilisez `scripts/download-sql.sh` ou placez le fichier manuellement
   - Vous pouvez télécharger manuellement depuis la [latest release](https://github.com/josoavj/ProspectiusFinal/releases/latest)

### Prérequis Minimums

| Élément | Exigence |
|---------|----------|
| **Flutter** | v3.16.0+ |
| **MariaDB** | 10.3+ |
| **MySQL** | 5.7+ |
| **Dart** | Inclus dans Flutter |
| **Git** | Pour le contrôle de version |

---

## 🔧 Utilisation Avancée

### Installation Silencieuse (Sans Prompts)

```bash
# Non pas actuellement supporté, à venir
# Les scripts posent des questions de confirmation
```

### Spécifier un Utilisateur MySQL Personnalisé

Modifiez les scripts avant exécution:

```bash
# Dans install-linux.sh, modifiez:
DB_USER="votre_utilisateur"
DB_PASSWORD="votre_mot_de_passe"
```

### Importer une Base de Données Existante

```bash
# Télécharger le SQL
bash download-sql.sh

# Importer manuellement
mysql -u root < scripts/Database/Prospectius.sql
```

### Désactiver Certaines Vérifications

Vous pouvez éditer les scripts pour sauter certaines vérifications (non recommandé).

---

## 📊 Ordre d'Exécution Recommandé

1. **setup.sh** → Installation automatique complète
2. **validate.sh** → Valider l'installation
3. **clean.sh** → (Optionnel) Nettoyer si problèmes

---

## 🆘 Dépannage

### Script Non Trouvé

```bash
cd prospectius  # Assurez-vous d'être dans le bon répertoire
bash scripts/setup.sh
```

### Permission Refusée (Linux/macOS)

```bash
chmod +x scripts/*.sh
bash scripts/setup.sh
```

### MySQL Non Détecté

- **Linux:** `sudo systemctl start mariadb`
- **macOS:** `brew services start mariadb`
- **Windows:** Services.msc → Chercher MariaDB → Démarrer

### Script SQL Non Trouvé

```bash
bash scripts/download-sql.sh
```

### PowerShell Policy Error (Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

---

## 📚 Documentation Supplémentaire

- **[README.md](../README.md)** - Vue d'ensemble du projet
- **[INSTALLATION.md](../INSTALLATION.md)** - Guide d'installation détaillé
- **[ENVIRONMENT.md](../ENVIRONMENT.md)** - Configuration des variables d'environnement
- **[CONFIGURATION.md](../CONFIGURATION.md)** - Paramètres par défaut

---

## 💡 Conseils et Bonnes Pratiques

1. **Toujours valider après installation:**

   ```bash
   bash scripts/validate.sh
   ```

2. **Garder les scripts à jour:**
   - Vérifiez les mises à jour du dépôt
   - Relancez les scripts après un `git pull`

3. **Sauvegarder la base de données:**

   ```bash
   mysqldump -u root Prospectius > backup.sql
   ```

4. **Nettoyer en cas de problèmes:**

   ```bash
   bash scripts/clean.sh
   ```

---

## 📞 Support

Pour les problèmes spécifiques:

- Vérifiez [INSTALLATION.md](../INSTALLATION.md)
- Consultez [ENVIRONMENT.md](../ENVIRONMENT.md)
- Exécutez `validate.sh` pour un diagnostic

---

**Dernière mise à jour:** 2024-11-29  
**Version:** 1.0.0
