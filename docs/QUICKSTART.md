# 🚀 Prospectius - Guide de Bienvenue

Bienvenue dans **Prospectius** ! Nous sommes ravis de vous aider à simplifier votre gestion commerciale. Ce guide vous accompagne pas à pas pour que vous soyez opérationnel en quelques minutes.

## 🎯 Quel est votre profil ?

### 👤 Je suis un Utilisateur
Vous voulez utiliser l'application pour gérer vos prospects sans toucher au code.

### 👨‍💻 Je suis un Développeur
Vous voulez explorer le code, le modifier ou compiler votre propre version personnalisée.

---

## ⚡ Guide pour les Utilisateurs (Installation Express)

### Étape 1 : Téléchargement
Rendez-vous sur la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest) et téléchargez les fichiers correspondant à votre système :
- **Windows :** `prospectius.exe`
- **Linux :** `prospectius`
- **Base de données :** `Prospectius.sql` (indispensable pour les deux)

### Étape 2 : Préparation de l'espace de stockage
Prospectius a besoin d'un moteur de base de données (MySQL ou MariaDB) pour fonctionner. 
1. **Installez MariaDB** sur votre ordinateur.
2. **Importez vos données :** Ouvrez votre terminal ou invite de commande et lancez :
   ```bash
   mysql -u root -p < Prospectius.sql
   ```

### Étape 3 : Lancement et Connexion
Double-cliquez sur l'icône **Prospectius**. Lors du premier lancement, l'application vous demandera vos identifiants MySQL. Une fois connecté, vous pourrez créer votre compte utilisateur et commencer à ajouter vos premiers prospects.

---

## 🛠️ Guide pour les Développeurs (Configuration Technique)

### 1. Préparation de l'environnement
Assurez-vous d'avoir **Flutter (3.16+)** et **MySQL/MariaDB** installés sur votre machine.

### 2. Installation du projet
```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
flutter pub get
```

### 3. Lancement en mode développement
```bash
# Pour Windows
flutter run -d windows
# Pour Linux
flutter run -d linux
```

---

## 🔐 Vos premiers pas dans l'application

Une fois Prospectius ouvert :

1. **Branchez la base de données :** Saisissez l'hôte (généralement `localhost`) et vos accès MySQL.
2. **Créez votre accès :** Cliquez sur "S'inscrire" pour créer votre profil commercial.
3. **Explorez :** Utilisez le Pipeline pour visualiser votre tunnel de vente ou l'Exploration pour retrouver rapidement un contact.

---

## ❓ Un souci ? Pas de panique !

### "Je ne vois pas mes données"
Vérifiez que votre serveur MariaDB ou MySQL est bien lancé. Sur Windows, vérifiez les Services système. Sur Linux, utilisez `sudo systemctl status mariadb`.

### "L'application ne s'ouvre pas"
Assurez-vous d'avoir téléchargé la version correspondant à votre système (64-bit requis).

### Besoin d'explications détaillées ?
- **[Le Manuel Complet](./INSTALLATION.md)** : Pour tout savoir sur l'installation.
- **[La Sécurité](./SECURITY.md)** : Pour comprendre comment nous protégeons vos données.

---

**Réalisé avec passion par APEXNova Labs © 2025**  
*Version 1.1.0 - Un CRM à votre image.*
