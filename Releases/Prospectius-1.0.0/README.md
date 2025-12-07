# Prospectius v1.0.0 - Release Finale

## 📱 Description

**Application CRM complète pour la gestion de prospects avec Flutter et MySQL.**

Prospectius est une solution professionnelle pour gérer vos prospects, suivre les interactions en temps réel et analyser vos statistiques de conversion. Conçue pour les équipes commerciales, elle offre une interface intuitive et performante pour optimiser votre prospection.

---

## 📦 Contenu du Package

```
Prospectius-1.0.0/
├── prospectius.exe              ✅ Application Windows exécutable (64-bit)
├── Prospectius.sql              ✅ Script de création base de données principale
├── SuppressionDB.sql            ✅ Script de base de données secondaire
├── README.md                     📖 Ce fichier
└── INSTALLATION.md              📖 Guide d'installation détaillé
```

---

## 🚀 Installation Rapide

### 1. Installation de la Base de Données

Vous devez d'abord installer **MySQL Server** sur votre ordinateur.

#### Étape 1 : Télécharger MySQL
- Visitez: https://dev.mysql.com/downloads/mysql/
- Téléchargez **MySQL Community Server** (version 5.7+ ou 8.0)

#### Étape 2 : Installer MySQL
1. Exécutez l'installateur téléchargé
2. Suivez l'assistant d'installation
3. Notez le **mot de passe root** (important!)
4. Vérifiez que MySQL est démarré (Services Windows)

#### Étape 3 : Importer les Scripts SQL
Ouvrez **MySQL Command Line Client** ou **MySQL Workbench** et exécutez:

```sql
-- Connectez-vous d'abord avec vos identifiants
mysql -u root -p

-- Importez les scripts
source C:\Chemin\Vers\Prospectius.sql
source C:\Chemin\Vers\SuppressionDB.sql

-- Vérifiez que les bases sont créées
SHOW DATABASES;
```

**Alternative avec PowerShell:**
```powershell
mysql -u root -p < "C:\Chemin\Vers\Prospectius.sql"
mysql -u root -p < "C:\Chemin\Vers\SuppressionDB.sql"
```

### 2. Configuration de l'Application

Lors du **premier lancement** de `prospectius.exe`, l'application vous demandera:

- ✅ **Adresse du serveur MySQL** (par défaut: `localhost`)
- ✅ **Nom d'utilisateur** (par défaut: `root`)
- ✅ **Mot de passe** (celui défini lors de l'installation MySQL)
- ✅ **Port** (par défaut: `3306`)

Ces paramètres sont sauvegardés pour les lancements suivants et peuvent être modifiés dans **Configuration > Base de Données**.

### 3. Lancer l'Application

**Simplement double-cliquez sur `prospectius.exe`** pour lancer l'application.

> **Première connexion**
> - Utilisateur: `demo`
> - Mot de passe: `demo`
> 
> Créez votre propre compte ensuite via "S'inscrire"

---

## 💻 Système Requis

| Critère | Minimum | Recommandé |
|---------|---------|-----------|
| **OS** | Windows 10 (64-bit) | Windows 11 (64-bit) |
| **RAM** | 4 GB | 8 GB |
| **Stockage** | 500 MB libres | 1 GB libres |
| **MySQL** | 5.7+ | 8.0 LTS |
| **Internet** | Optionnel | Pour mises à jour |

---

## ✨ Fonctionnalités Principales

- ✅ **Gestion complète des prospects**
  - Liste complète avec statuts
  - Ajout/édition en temps réel
  - Suppression sécurisée avec audit
  - Recherche et filtrage avancés

- ✅ **Historique des interactions**
  - Enregistrement (appel, email, réunion, etc.)
  - Notes détaillées et dates de suivi
  - Historique complet par prospect
  - Types d'interaction configurables

- ✅ **Statistiques et analyses**
  - Graphiques en temps réel
  - Taux de conversion avec tendances
  - Tableau de bord personnalisé
  - Export Excel complet

- ✅ **Authentification sécurisée**
  - Login multi-utilisateur
  - Mots de passe chiffrés (bcrypt)
  - Gestion des sessions
  - Récupération de mot de passe

- ✅ **Audit et conformité**
  - Logging de toutes les opérations
  - Historique d'audit complet
  - Traçabilité des modifications
  - Rapports de conformité

- ✅ **Interface utilisateur**
  - Design moderne (Material Design 3)
  - Navigation intuitive
  - Responsive et fluide
  - Thème clair/sombre

---

## 🚀 Installation

### Prérequis
- **Flutter 3.0+**
- **Dart 3.0+**
- **MySQL/MariaDB 5.7+**
- **Node.js 16+** (optionnel, pour le serveur backend)

### Installation Rapide

#### 1. Cloner le projet
```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
```

#### 2. Installation des dépendances
```bash
flutter pub get
```

#### 3. Configuration de la base de données
```bash
# Linux/macOS
./scripts/setup.sh

# Windows
.\scripts\install-windows.ps1
```

#### 4. Lancer l'application
```bash
flutter run
```

---

## 📋 Configuration

### Configuration de la Base de Données

#### Fichier `lib/config/database_config.dart`
```dart
const String dbHost = 'localhost';
const int dbPort = 3306;
const String dbUser = 'root';
const String dbPassword = 'votre_mot_de_passe';
const String dbName = 'Prospectius';
```

#### Créer la base de données
```bash
mysql -u root -p < scripts/Database/Prospectius.sql
```

### Variables d'Environnement
```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=password
export DB_NAME=Prospectius
```

---

## 🏗️ Architecture

### Structure du Projet
```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   ├── account.dart
│   ├── prospect.dart
│   ├── interaction.dart
│   ├── status_history.dart
│   └── stats.dart
├── services/                 # Logique métier
│   ├── database_service.dart
│   ├── mysql_service.dart
│   ├── auth_service.dart
│   ├── prospect_service.dart
│   ├── transfer_service.dart
│   ├── audit_service.dart
│   └── error_handling_service.dart
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── prospect_provider.dart
│   ├── stats_provider.dart
│   └── audit_provider.dart
├── screens/                  # Écrans UI
│   ├── login_screen.dart
│   ├── prospects_screen.dart
│   ├── stats_screen.dart
│   ├── configuration_screen.dart
│   └── ...
└── utils/                    # Utilitaires
    ├── app_logger.dart
    └── constants.dart
```

### Architectures Utilisées
- **MVVM** (Model-View-ViewModel)
- **Provider** pour la gestion d'état
- **Clean Architecture** pour la séparation des responsabilités
- **Repository Pattern** pour l'accès aux données

---

## 📚 Utilisateurs et Authentification

### Créer un Compte
1. Cliquer sur "S'inscrire" sur l'écran de login
2. Entrer nom d'utilisateur et mot de passe
3. Le compte est créé automatiquement

### Statuts des Prospects
- **Nouveau** - Prospect fraîchement ajouté
- **En contact** - Discussions en cours
- **En cours de négociation** - Négociation avancée
- **Client** - Prospect converti
- **Perte** - Prospect perdu



---

## 🎯 Démarrage Rapide

### Créer votre Premier Prospect

1. **Connectez-vous** avec vos identifiants
2. Cliquez sur **"Ajouter un prospect"**
3. Remplissez les informations (nom, entreprise, etc.)
4. Cliquez sur **"Enregistrer"**
5. Commencez à suivre vos interactions!

### Statuts des Prospects

| Statut | Description |
|--------|-------------|
| 🆕 **Nouveau** | Prospect fraîchement ajouté |
| 📞 **En contact** | Discussions en cours |
| 💼 **En négociation** | Négociation avancée |
| ✅ **Client** | Prospect converti |
| ❌ **Perte** | Prospect perdu/rejeté |

### Suivre les Interactions

1. Ouvrez la **fiche prospect**
2. Cliquez sur **"Ajouter une interaction"**
3. Sélectionnez le **type** (appel, email, réunion, etc.)
4. Ajoutez vos **notes**
5. **Enregistrez** automatiquement

---

## ⚙️ Configuration Avancée

### Modifier les Paramètres MySQL

1. Allez dans **Configuration > Base de Données**
2. Modifiez les paramètres (hôte, utilisateur, port)
3. Cliquez sur **"Tester la connexion"**
4. **Enregistrez** les nouveaux paramètres

### Exporter vos Données

1. Allez dans **Prospects > Exporter**
2. Sélectionnez la **plage de dates**
3. Cliquez sur **"Télécharger Excel"**
4. Les données s'ouvrent dans votre tableur préféré

### Consulter les Logs d'Audit

1. Allez dans **Administration > Logs d'audit**
2. Filtrez par **date**, **utilisateur**, **action**
3. Exportez les rapports si nécessaire

---

## 🐛 Dépannage Courant

### Erreur: "Can't connect to MySQL server"

**Cause**: MySQL n'est pas en cours d'exécution

**Solutions**:
1. Ouvrez **Services Windows** (`services.msc`)
2. Cherchez **MySQL80** (ou votre version)
3. Cliquez droit → **Démarrer**

Ou en PowerShell (Admin):
```powershell
Start-Service MySQL80
```

---

### Erreur: "Access denied for user 'root'"

**Cause**: Mot de passe incorrect

**Solutions**:
1. Allez dans **Configuration > Base de Données**
2. Vérifiez votre mot de passe MySQL
3. Cliquez sur **"Tester la connexion"**
4. Réinitialisez le mot de passe si nécessaire:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'nouveau_mot_de_passe';
FLUSH PRIVILEGES;
```

---

### Erreur: "Table 'Prospectius.Prospect' doesn't exist"

**Cause**: Scripts SQL non importés correctement

**Solutions**:
1. Supprimez la base de données: `DROP DATABASE Prospectius;`
2. Réimportez les scripts SQL
3. Redémarrez l'application

```sql
mysql -u root -p < Prospectius.sql
```

---

### L'application met longtemps à charger

**Cause**: Connexion lente ou trop de données

**Solutions**:
- ✅ Vérifiez votre connexion à MySQL
- ✅ Réduisez la plage de données affichées
- ✅ Videz le cache: **Configuration > Nettoyage du cache**
- ✅ Redémarrez MySQL si stressé

---

## 📊 Schéma de Base de Données

### Tables Principales

```sql
-- Utilisateurs
Account
  ├── id_compte (PK)
  ├── username
  ├── password_hash
  ├── email
  └── created_at

-- Prospects
Prospect
  ├── id_prospect (PK)
  ├── id_compte (FK)
  ├── name
  ├── status
  ├── company
  └── created_at

-- Interactions
Interaction
  ├── id_interaction (PK)
  ├── id_prospect (FK)
  ├── id_compte (FK)
  ├── interaction_type
  ├── note
  └── interaction_date

-- Historique des statuts
StatusHistory
  ├── id_history (PK)
  ├── id_prospect (FK)
  ├── old_status
  ├── new_status
  └── changed_date

-- Transferts
TransferHistory
  ├── id_transfer (PK)
  ├── id_prospect (FK)
  ├── from_user_id (FK)
  ├── to_user_id (FK)
  └── transfer_date

-- Audit
audit_logs
  ├── id (PK)
  ├── user_id (FK)
  ├── action
  ├── table_name
  ├── record_id
  └── timestamp
```

---

## 🔐 Sécurité

### Bonnes Pratiques

- ✅ **Mots de passe chiffrés** avec bcrypt
- ✅ **Audit complet** de toutes les opérations
- ✅ **Validation** des entrées utilisateur
- ✅ **Gestion sécurisée** des sessions
- ✅ **Pas de stockage** de données sensibles
- ✅ **Sauvegarde régulière** de la base de données

### Sauvegarder votre Base de Données

```powershell
# Sauvegarde complète
mysqldump -u root -p Prospectius > backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql

# Restauration
mysql -u root -p Prospectius < backup.sql
```

---

## 📞 Support et Contact

### Problèmes Fréquents

- **[FAQ](./FAQ.md)** - Questions fréquemment posées
- **[QUICKSTART.md](../../../QUICKSTART.md)** - Guide de démarrage
- **[INSTALLATION.md](../../../INSTALLATION.md)** - Installation détaillée

### Signaler un Bug

1. Ouvrez une **issue** sur GitHub
2. Décrivez le problème avec détails
3. Joignez les **logs** (Configuration > Logs)
4. Signalez votre **version** et **OS**

### Contacter l'Équipe

- **Email**: support@prospectius.app
- **GitHub**: https://github.com/josoavj/ProspectiusFinal/issues
- **Wiki**: https://github.com/josoavj/ProspectiusFinal/wiki

---

## 📋 Information Technique

| Propriété | Valeur |
|-----------|--------|
| **Version** | 1.0.0 |
| **Date de Release** | 7 décembre 2025 |
| **Plateforme** | Windows 64-bit |
| **Framework** | Flutter 3.38.3+ |
| **Langage** | Dart 3.0+ |
| **Base de données** | MySQL 5.7+ / MariaDB 10.5+ |
| **Licence** | MIT |

---

## 🎯 Feuille de Route

### v1.0.0 ✅ (Actuel)
- Gestion complète des prospects
- Suivi des interactions
- Statistiques et analyses
- Authentification utilisateur
- Audit complet

### v1.1.0 (Q1 2026)
- Calendrier des suivis
- Intégration email
- Export PDF avancé
- Notifications push
- Rapports personnalisés

### v2.0.0 (H1 2026)
- App mobile native (iOS/Android)
- API REST publique
- Synchronisation cloud
- IA pour recommandations
- Webhooks et intégrations

---

## 📜 Licence

Prospectius est sous licence **MIT**. Vous êtes libre d'utiliser, modifier et distribuer cette application.

---

## 👨‍💻 À Propos

Développé par **Joseph Avila** (@josoavj)

**Remerciements spéciaux** aux contributeurs et utilisateurs bêta qui ont aidé à améliorer Prospectius.

---

**🚀 Profitez de Prospectius et optimisez votre prospection!**

*Dernière mise à jour: 7 décembre 2025*
*Support Windows 10+ (64-bit)*
