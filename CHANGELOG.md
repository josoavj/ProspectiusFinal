# Journal des Modifications - Prospectius

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

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
