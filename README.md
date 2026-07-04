
<h1 align="center">Prospectius</h1>

<p align="center">
  <strong>Transformez vos relations commerciales en succès durable</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.1.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/database-MySQL-orange" alt="Database">
  <img src="https://img.shields.io/github/last-commit/josoavj/ProspectiusFinal?style=flat-square" alt="Last Commit">
</p>

## 🌟 Pourquoi Prospectius ?

Prospectius n'est pas seulement un outil de gestion, c'est le partenaire de votre croissance commerciale. Conçu pour simplifier la vie des commerciaux et des entrepreneurs, il vous aide à centraliser vos contacts, à visualiser vos opportunités et à ne jamais perdre le fil d'un échange important.

## ✨ Ce que vous pouvez faire avec Prospectius

### 📂 Un carnet d'adresses intelligent
Regroupez toutes les informations de vos prospects au même endroit. Fini les notes volantes ou les fichiers Excel oubliés. Que ce soit une entreprise ou un particulier, chaque fiche contient tout ce dont vous avez besoin pour réussir.

### 🎢 Visualisez votre réussite avec le Pipeline
Suivez l'avancée de vos opportunités sur un tableau intuitif. Faites glisser vos prospects d'une étape à l'autre (Nouveau, Intéressé, Négociation...) et voyez votre tunnel de vente se remplir.

### 🧠 La mémoire de vos relations
Notez chaque appel, chaque email et chaque réunion. Prospectius garde l'historique complet de vos échanges pour que vous sachiez exactement où vous en êtes lors de votre prochaine relance.

### ⏱️ Zéro oubli, plus de ventes
Planifiez des rappels et des tâches directement sur vos fiches prospects. L'application vous aide à prioriser vos actions pour ne jamais laisser passer une opportunité cruciale.

### 📈 Comprenez vos résultats
Visualisez vos performances grâce à des statistiques simples et claires. Analysez vos taux de conversion pour savoir ce qui fonctionne le mieux dans votre stratégie.

---

## ⚡ Installation Rapide

### 👤 Pour les Utilisateurs

**Étape 1 : Téléchargement**
Téléchargez la version adaptée à votre ordinateur (Windows ou Linux) sur la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest).

**Étape 2 : Préparation de la base de données**
Prospectius utilise MySQL ou MariaDB pour stocker vos données en toute sécurité sur votre propre machine ou serveur.
1. Installez MariaDB ou MySQL.
2. Importez le fichier `Prospectius.sql` fourni.

**Étape 3 : Premier lancement**
Lancez l'application. Lors de la première ouverture, saisissez vos identifiants de base de données pour connecter Prospectius à votre espace de stockage.

---

## 👨‍💻 Pour les Développeurs

Le projet est construit avec **Flutter** et suit une architecture propre (Clean Architecture) pour une maintenance simplifiée.

### Configuration Express
```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
flutter pub get
# Activez votre plateforme
flutter config --enable-windows-desktop 
flutter config --enable-linux-desktop
```

### Lancement
```bash
# Windows
flutter run -d windows
# Linux
flutter run -d linux
```

---

## 📁 Structure du projet

- **lib/presentation** : Tout ce que l'utilisateur voit et touche (écrans, widgets).
- **lib/domain** : Les règles métier et la logique pure de l'application.
- **lib/data** : Le pont vers votre base de données MySQL.
- **lib/providers** : Le cerveau qui coordonne l'affichage et les données.

## 👥 L'Équipe derrière le projet

- **Vision & Développement Principal :** [josoavj](https://github.com/josoavj)
- **Expérience Utilisateur & Design :** [Maminirina ANDRIAMASINORO](https://github.com/AinaMaminirina18)

## 📝 Notice de Sécurité

Prospectius est conçu pour respecter la confidentialité de vos données commerciales. Toutes les informations sont stockées localement sur votre instance MySQL. Pour plus de détails, consultez notre [Politique de Sécurité](./SECURITY.md).

---
*Réalisé avec passion par APEXNova Labs © 2025*
