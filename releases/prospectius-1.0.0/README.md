# Prospectius 1.0.0 - Release Windows

## Description
Application CRM complète pour la gestion de prospects avec Flutter et MySQL.

## Contenu du package

- **prospectius.exe** : Application Windows exécutable (64-bit)
- **Prospectius.sql** : Script de création de la base de données principale
- **SuppressionDB.sql** : Script de base de données secondaire

## Installation

### 1. Installation de la base de données
Vous devez d'abord installer MySQL Server sur votre ordinateur.

1. Téléchargez MySQL Community Server depuis : https://dev.mysql.com/downloads/mysql/
2. Installez MySQL Server
3. Ouvrez MySQL Command Line Client ou MySQL Workbench
4. Importez les scripts SQL :
   ```sql
   -- Créer les bases de données
   source /chemin/vers/Prospectius.sql
   source /chemin/vers/SuppressionDB.sql
   ```

### 2. Configuration de l'application
Lors du premier lancement de `prospectius.exe`, l'application vous demandera :
- Adresse du serveur MySQL
- Nom d'utilisateur
- Mot de passe
- Port (par défaut 3306)

### 3. Lancer l'application
Double-cliquez sur `prospectius.exe` pour lancer l'application.

## Système requis

- **OS** : Windows 10 ou supérieur (64-bit)
- **RAM** : 4 GB minimum, 8 GB recommandé
- **Stockage** : 500 MB libres
- **MySQL** : 5.7+ ou MariaDB 10.5+
- **Connexion Internet** : Pour la synchronisation optionnelle

## Fonctionnalités

- ✅ Gestion complète des prospects
- ✅ Historique d'interactions
- ✅ Statistiques en temps réel
- ✅ Export Excel
- ✅ Authentification sécurisée
- ✅ Interface moderne avec Material Design

## Support

Pour plus d'informations, consultez le fichier QUICKSTART.md ou README.md du projet source.

---
**Version** : 1.0.0  
**Date de release** : 3 décembre 2025  
**Plateforme** : Windows 64-bit  
**Développé avec** : Flutter 3.38.3
