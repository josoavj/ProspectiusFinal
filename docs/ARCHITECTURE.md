# Dans les coulisses de Prospectius : Notre Architecture

Ce document explique comment Prospectius est construit. Pour garantir que l'application reste rapide, fiable et facile à faire évoluer, nous avons choisi une organisation structurée combinant **Clean Architecture** et une approche **Feature-first** pour la couche de présentation.

---

## L'organisation en couches

### La Salle (Présentation) - `lib/screens` & `lib/widgets`

C'est l'interface utilisateur. Pour maximiser la scalabilité, nous utilisons une structure **organisée par fonctionnalités (Features)** :

- **`lib/screens/auth/`** : Gestion de l'accès (Connexion, Inscription).
- **`lib/screens/prospects/`** : Cycle de vie complet des prospects.
- **`lib/screens/dashboard/`** : Outils d'analyse (Kanban, Stats, Exploration).
- **`lib/screens/settings/`** : Configuration technique et profil.

#### Modularisation des Composants

Chaque dossier de fonctionnalité contient un sous-dossier `widgets/` pour extraire la logique UI complexe (ex: `StatusChip`, `ConversionCard`). Cela permet de garder les fichiers d'écrans (`_screen.dart`) légers et focalisés sur la structure de la page.

#### Gestion d'État (Provider)

Utilisation de `provider` pour une réactivité fluide. Chaque domaine possède son propre fournisseur (ex: `ProspectProvider`, `AuthProvider`), assurant une séparation claire des responsabilités.

### Les Recettes (Domaine) - `lib/domain`

Définit les entités métier (Prospect, Interaction) et les contrats de services (Interfaces des Repositories). C'est le code le plus stable, indépendant des technologies externes.

### La Cuisine (Données) - `lib/data`
Implémente l'accès aux données. Elle communique avec le serveur MySQL via des requêtes optimisées et gère la mise en cache locale pour des performances instantanées.

---

## Services Techniques Majeurs

1. **MySQL Engine** : Gère les connexions persistantes, les pools de connexions et le diagnostic système.
2. **Backup Service** : Moteur d'extraction SQL capable de reconstruire l'intégralité de la base de données.
3. **Migration Service** : Met à jour automatiquement le schéma de la base de données sans perte de données.
4. **Auth Service** : Sécurise les sessions via BCrypt et le stockage d'identifiants sécurisé.

---

## Innovations et Robustesse

- **Structure Modulaire** : Facilite le travail en équipe en limitant les conflits sur les fichiers monolithiques.
- **Assistant Wizard** : Navigation par étapes avec validation granulaire.
- **Moteur Multi-phone** : Gestion native de la complexité des numéros multiples.
- **Verrouillage Optimiste** : Protection contre les modifications concurrentes via un système de versioning.

---

*Prospectius : Une base solide pour une croissance sereine. APEXNova Labs © 2025*
