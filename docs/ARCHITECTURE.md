# Dans les coulisses de Prospectius : Notre Architecture

Ce document explique comment Prospectius est construit. Pour garantir que l'application reste rapide, fiable et facile à faire évoluer, nous avons choisi une organisation structurée appelée **Clean Architecture**.

---

## 🏛️ L'organisation en couches

### 🍽️ La Salle (Présentation) - `lib/screens` & `lib/widgets`
C'est l'interface utilisateur. Elle s'occupe d'afficher les données et de capturer les interactions (clics, glissements Kanban).
- **Gestion d'État (Provider)** : Utilisation de `provider` pour une réactivité fluide. Chaque module (Prospects, Stats, Auth, Settings) possède son propre fournisseur de données.

### 📜 Les Recettes (Domaine) - `lib/domain`
Définit les entités métier (Prospect, Interaction) et les contrats de services (Interfaces des Repositories). C'est le code le plus stable, indépendant des technologies externes.

### 🍳 La Cuisine (Données) - `lib/data`
Implémente l'accès aux données. Elle communique avec le serveur MySQL via des requêtes optimisées et gère la mise en cache locale pour des performances instantanées.

---

## 🏗️ Services Techniques Majeurs

1. **MySQL Engine** : Gère les connexions persistantes, les pools de connexions et le diagnostic système.
2. **Backup Service** : Moteur d'extraction SQL capable de reconstruire l'intégralité de la base de données.
3. **Migration Service** : Met à jour automatiquement le schéma de la base de données lors du passage à une nouvelle version sans perte de données.
4. **Auth Service** : Sécurise les sessions via BCrypt et le stockage d'identifiants sécurisé.

---

## 🔒 Innovations de la Version 1.2.0

- **Assistant Wizard** : Navigation par étapes avec persistance temporaire de l'état du formulaire.
- **Moteur Multi-phone** : Normalisation des numéros de téléphone (Stockage 10 chiffres vs Affichage formatté).
- **Résilience Database** : Logique de répétition (retry) et reconnexion transparente.
- **Verrouillage Optimiste** : Champ `version` incrémenté à chaque modification pour garantir l'intégrité en mode multi-utilisateur.

---

*Prospectius : Une base solide pour une croissance sereine. APEXNova Labs © 2025*
