# Journal des Modifications - Prospectius

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

## [Non publiée] - 2026-10-30

### Authentification et comptes
- Refonte des écrans de connexion, d'inscription et de récupération du compte administrateur.
- Conservation du panneau de marque à gauche pendant le changement du formulaire à droite.
- Ajout de transitions fluides entre les parcours d'authentification.
- Création sécurisée du premier administrateur avec code de récupération à usage unique.
- Hachage BCrypt des codes de récupération avant leur stockage.
- Régénération du code de récupération après vérification du mot de passe administrateur.
- Export du code de récupération dans un fichier texte desktop.
- Acceptation obligatoire des conditions d'utilisation et de la politique de confidentialité avant inscription.
- Gestion administrative des comptes, des rôles et des suppressions avec confirmation sécurisée.
- Protection du dernier administrateur et limitation à trois administrateurs.

### Base de données et sécurité
- Fiabilisation du pool de connexions MariaDB/MySQL pour les usages multi-utilisateurs.
- Sérialisation des connexions concurrentes et remplacement des connexions défectueuses.
- Limitation des retries automatiques aux lectures pouvant être rejouées sans risque.
- Ajout de transactions explicites pour les verrous `SELECT ... FOR UPDATE`.
- Gestion des commits, rollbacks, deadlocks et expirations d'attente de verrous.
- Validation des tables et colonnes utilisées pour les verrous dynamiques.
- Blocage de la connexion lorsque l'initialisation du schéma ou les migrations échouent.
- Correction et synchronisation des triggers et règles de gestion des administrateurs.
- Distribution des scripts `Prospectius.sql` et `SuppressionDB.sql` avec les releases desktop.

### Interface et identité visuelle
- Harmonisation de la palette et des transitions de navigation.
- Remplacement de l'ancien logo par l'icône principale `icon.png` dans la navigation et les écrans concernés.
- Mise à jour de l'icône Windows et des ressources de marque.
- Suppression des références obsolètes à un ancien contributeur dans la présentation et la documentation.
- Suppression du double AppBar dans la page des journaux système.
- Adaptation de la configuration aux plateformes Linux, Windows et macOS.

### Présentation et documentation
- Ajout d'une présentation HTML complète dans `presentation/`.
- Séparation du CSS et du JavaScript de `presentation/index.html` dans `presentation/presentation.css` et `presentation/presentation.js`.
- Ajout des logos et favicons nécessaires à la présentation.
- Ajout d'un workflow de déploiement GitHub Pages.
- Mise à jour de la page À propos et de l'aide intégrée sur les comptes et la récupération.
- Mise à jour du README et des informations de présentation du projet.

### Distribution et CI
- Ajout d'un workflow de release Linux avec Flutter 3.47.1.
- Mise à jour du workflow Windows vers Flutter 3.47.1.
- Installation de `libsecret-1-dev` pour compiler `flutter_secure_storage` sous Linux.
- Création d'une archive Windows ZIP contenant le bundle complet et les scripts SQL.
- Création automatique d'un installateur Windows Inno Setup `.exe` complet.
- Création d'une archive Linux TAR.GZ contenant le bundle complet et les scripts SQL.
- Création d'un paquet Linux Debian/Ubuntu `.deb` avec lanceur d'application.
- Synchronisation de la version applicative `1.2.0` avec les artefacts de release.
- Publication automatique des archives sur les GitHub Releases lors d'un tag `v*`.
- Ajout d'un déclenchement manuel des workflows de release.

### Validation
- Dépendances Flutter résolues avec Dart compatible avec `flutter_lints` et `shimmer`.
- Tests Flutter existants validés.
- Compilation Linux debug et release validée.
- Vérification de la syntaxe et des chemins des workflows GitHub Actions.

## [1.2.0] - 2025-02-12

### Nouvelles Fonctionnalités
- **Assistant d'Ajout (Wizard)** : Refonte totale de la création de prospect en 5 étapes structurées avec navigation fluide et effet de flou.
- **Gestion Multi-numéros** : Support de **3 numéros de téléphone** par prospect avec formatage Malagasy automatique (+261).
- **Cycle de Vie Simplifié** : Suppression du statut "Nouveau". Tout prospect débute désormais par défaut à **"Intéressé"**.
- **Sauvegarde SQL Intégrée** : Option de sauvegarde complète (Structure + Données) avec choix du répertoire (Standard ou Personnalisé).
- **Indicateur de Santé Système** : Nouveau tableau de bord de diagnostic technique (Version DB, Mode connexion, Statut serveur).
- **Showcase de l'Arsenal** : Dialogue interactif "Arsenal Prospectius" présentant toutes les capacités de l'outil.

### Sécurité & Données
- **Consentement RGPD Dynamique** : Refonte de la section protection avec choix rapides (Tags) et pédagogie intégrée.
- **Identité Professionnelle** : Harmonisation de l'affichage en **NOM Prénom** sur toute la plateforme.
- **Nettoyage Automatique** : Amélioration de la purge des données supprimées avec sécurisation du contexte asynchrone.

### Design & Expérience (UX)
- **Transitions Premium** : Fluidification des changements d'écrans (Login, Splash, Aide) avec des animations de fondu et glissement.
- **Profil Majestic** : Refonte de l'écran Profil avec en-tête bleu uni et avatar circulaire flottant.
- **Page À Propos** : Nouvelle vitrine moderne avec présentation détaillée de l'équipe Core (Postes FullStack) et avatars GitHub.
- **Navigation Optimisée** : Harmonisation des titres de l'AppBar et des boutons d'actualisation sur tous les écrans.

## [1.1.0] - 2025-01-20

### Nouvelles Fonctionnalités
- **Conformité RGPD** : Ajout du suivi natif du consentement (date et source) sur chaque fiche prospect.
- **Parcours du Prospect** : Nouvel onglet affichant l'historique complet des changements de statut sous forme de timeline.
- **Maintenance Admin** : Ajout d'une option pour purger définitivement les données supprimées depuis plus de 30 jours.
- **Raccourcis Clavier Windows** : Support natif de `Ctrl+F` (Recherche), `Ctrl+N` (Nouveau) et `Échap` (Fermer).
- **Installeur Windows** : Script Inno Setup pour générer un fichier `.exe` de production professionnel.

### Sécurité & Stabilité
- **Verrouillage Optimiste** : Implémentation d'un système de versioning pour éviter l'écrasement de données lors de modifications simultanées.
- **Résilience SQL** : Ajout d'une logique de reconnexion automatique avec 3 tentatives en cas de micro-coupure réseau.
- **Journalisation Pro** : Logging des erreurs SQL et système dans des fichiers journaux locaux sur le poste utilisateur.
- **RBAC (Access Control)** : Sécurisation des accès aux données selon le rôle de l'utilisateur (Admin vs Commercial).

### Design & Interface
- **Identité Visuelle** : Nouveau logo officiel et palette de couleurs basée sur le bleu Royal professionnel.
- **Fiche Détail Premium** : Refonte totale avec entête "Sliver" animée, avatar Hero et navigation par onglets synchronisée.
- **Pipeline Kanban** : Modernisation visuelle du tableau de bord avec indicateurs de priorité.
- **Documents & Médias** : Ajout de la prévisualisation directe des images et gestion des vignettes.

### Documentation
- **Aide Intégrée** : Création de guides pédagogiques directement accessibles dans l'application (Démarrage, Clavier, Sécurité).
- **Refonte des Manuels** : Mise à jour complète de la documentation technique et utilisateur avec un ton plus accessible.

---

## [1.0.1] - 2024-11-29
- Initialisation de la version stable.
- Gestion de base des prospects et interactions.
- Export Excel et statistiques de conversion.
- Support multi-plateforme Windows/Linux.

---
*Réalisé par APEXNova Labs © 2025*
