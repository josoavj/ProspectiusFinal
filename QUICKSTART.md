# 🚀 Prospectius - Démarrage Rapide

Bienvenue dans **Prospectius**, une application CRM Flutter moderne pour Windows et Linux.

## ⚡ Installation en 2 Étapes

### Étape 1: Télécharger et Préparer

```bash
git clone <votre-repo-url>
cd prospectius
```

### Étape 2: Exécuter le Script d'Installation

**Sur Linux ou macOS:**
```bash
bash scripts/setup.sh
```

**Sur Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

C'est tout ! Le script s'occupe de:
- ✅ Vérifier/installer MariaDB
- ✅ Importer la base de données
- ✅ Installer les dépendances Flutter
- ✅ Afficher les instructions de lancement

---

## 📱 Lancer l'Application

Après installation:

```bash
flutter run
```

Pour Windows spécifiquement:
```bash
flutter run -d windows
```

Pour Linux spécifiquement:
```bash
flutter run -d linux
```

---

## 🔐 Premier Accès

Une fois l'app lancée:

### 1. Configuration de la Base de Données
À la première exécution, vous devrez configurer la connexion:

```
Host: localhost
Port: 3306
User: root
Password: root
Database: Prospectius
```

### 2. Connexion
Utilisez les identifiants par défaut:

```
Username: admin
Password: admin
```

---

## ❓ Besoin d'Aide?

### Validation de l'Installation
```bash
bash scripts/validate.sh
```

Cela affiche un diagnostic complet du système.

### Nettoyage et Réinitialisation
```bash
bash scripts/clean.sh
```

Nettoie les caches et réinstalle les dépendances.

### Documentation Complète

- **[INSTALLATION.md](INSTALLATION.md)** - Guide détaillé pour chaque OS
- **[ENVIRONMENT.md](ENVIRONMENT.md)** - Variables et configuration
- **[scripts/README.md](scripts/README.md)** - Documentation des scripts
- **[README.md](README.md)** - Vue d'ensemble du projet

---

## 🐛 Problèmes Courants

### "MariaDB non trouvé"
```bash
# Linux (Ubuntu/Debian)
sudo systemctl start mariadb

# macOS
brew services start mariadb

# Windows
# Services.msc → Chercher "MariaDB" → Démarrer
```

### "Flutter non trouvé"
Installez Flutter: https://flutter.dev/docs/get-started/install

### "Base de données non importée"
```bash
bash scripts/download-sql.sh
mysql -u root -proot < scripts/prospectius.sql
```

---

## 🎯 Fonctionnalités Principales

✅ **Gestion de Prospects**
- Ajouter/modifier/supprimer des prospects
- Classer par statut (Nouveau, En cours, Qualifié, etc.)
- Ajouter des notes et contacts

✅ **Suivi des Interactions**
- Enregistrer les interactions avec les prospects
- Historique complet par prospect

✅ **Statistiques**
- Tableau de bord avec métriques clés
- Taux de conversion
- Distribution par statut

✅ **Authentification**
- Connexion sécurisée
- Gestion des comptes utilisateurs

---

## 📋 Prérequis Système

| Plateforme | Req. Minimum | Recommandé |
|-----------|-------------|-----------|
| **Windows** | 8.1+ | Windows 10+ |
| **Linux** | Ubuntu 18.04+ | Ubuntu 22.04+ |
| **macOS** | 10.11+ | 12.0+ |

**Logiciels:**
- Flutter 3.16.0+
- MariaDB 10.3+ ou MySQL 5.7+

---

## 🔧 Configuration Avancée

Pour des configurations personnalisées, consultez:
- [ENVIRONMENT.md](ENVIRONMENT.md) pour les variables
- [CONFIGURATION.md](CONFIGURATION.md) pour les paramètres par défaut
- [scripts/README.md](scripts/README.md) pour les options des scripts

---

## 🤝 Contribution

Pour contribuer au projet:

1. Fork le dépôt
2. Créez une branche (`git checkout -b feature/improvement`)
3. Commitez vos changements (`git commit -am 'Add improvement'`)
4. Poussez vers la branche (`git push origin feature/improvement`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Tous droits réservés.

---

## 📞 Support

Pour toute question ou problème:
1. Exécutez `bash scripts/validate.sh` pour un diagnostic
2. Consultez la [documentation](./docs)
3. Vérifiez les [issues existantes](../../issues)

---

**Version:** 1.0.0  
**Dernière mise à jour:** 2024-11-29

Bon démarrage! 🎉
