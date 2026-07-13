# Prospectius - Guide de Bienvenue

Bienvenue dans **Prospectius** ! Nous sommes ravis de vous aider à simplifier votre gestion commerciale. Ce guide vous accompagne pas à pas pour que vous soyez opérationnel avec la version 1.2.0.

## Quel est votre profil ?

### 👤 Je suis un Utilisateur
Vous voulez utiliser l'application pour gérer vos prospects sans toucher au code.

### 👨‍💻 Je suis un Développeur
Vous voulez explorer le code, le modifier ou compiler votre propre version personnalisée.

---

## Guide pour les Utilisateurs (Installation Express)

### Étape 1 : Téléchargement
Récupérez l'installeur correspondant à votre système :
- **Windows :** `Prospectius_Setup_v1.2.0.exe`
- **Linux :** Téléchargez l'exécutable `prospectius` (Donnez-lui les droits d'exécution).

### Étape 2 : Stockage (MySQL)
Prospectius a besoin de MySQL ou MariaDB.
1. Installez MariaDB sur votre PC ou serveur.
2. Notez vos accès (Hôte, Utilisateur, Mot de passe).

### Étape 3 : Connexion
Lancez l'application. Elle préparera votre base de données automatiquement lors de la première connexion à votre serveur MySQL.

---

## Les Nouveautés de la v1.2.0 à tester

1. **L'Assistant d'Ajout** : Cliquez sur le bouton "+" et laissez-vous guider par les 5 étapes (Identité, Digital, RGPD, Premier échange, Récap).
2. **Le multi-numéro** : Essayez d'ajouter plusieurs numéros à un prospect. Ils sont formattés automatiquement pour Madagascar (+261).
3. **Le Pipeline Kanban** : Glissez vos prospects vers "Converti" pour transformer votre effort en succès.
4. **La Sauvegarde** : Allez dans Paramètres > Sécurité pour générer votre premier fichier de backup SQL.

---

## Guide pour les Développeurs

### 1. Environnement
- Flutter 3.16+
- MariaDB / MySQL 10.0+

### 2. Installation
```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
flutter pub get
```

### 3. Lancement
```bash
flutter run -d windows # ou linux
```

---

## ❓ Un souci ? 

### "Je ne vois pas mes données"
Vérifiez que le service MariaDB est bien lancé dans les paramètres de votre PC.

### Besoin d'aide visuelle ?
Consultez le **Guide de démarrage rapide** directement dans l'application via l'onglet **Paramètres**.

---

**Réalisé avec passion par APEXNova Labs © 2025**  
*Version 1.2.0 - Propulsez votre croissance.*
