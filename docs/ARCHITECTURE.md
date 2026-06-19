# Architecture du Projet - Prospectius

Ce document détaille l'architecture technique de Prospectius, basée sur les principes de la **Clean Architecture** et du **Repository Pattern**.

---

## 🏛️ Vue d'ensemble

Prospectius utilise une architecture en couches pour séparer les responsabilités et faciliter la maintenance, les tests et l'évolution future (ex: passer d'une connexion MySQL directe à une API REST).

```
lib/
├── core/                # Noyau (Injection, Constantes, Thèmes)
├── data/                # Couche de Données (Implémentation)
├── domain/              # Couche de Domaine (Contrats)
├── models/              # Entités Métier (DTOs)
├── providers/           # Gestion d'État (Presentation Logic)
├── screens/             # UI - Écrans
├── services/            # Services Techniques
├── widgets/             # UI - Composants réutilisables
└── utils/               # Utilitaires
```

---

## 🏗️ Les Couches

### 1. Domaine (Domain)
C'est le cœur de l'application. Elle contient les **interfaces** (contrats) des dépôts. Elle ne dépend d'aucune autre couche technique.
- **Fichiers**: `lib/domain/repositories/i_prospect_repository.dart`

### 2. Données (Data)
Cette couche implémente les interfaces définies dans le Domaine. Elle gère la communication avec les sources de données (MySQL, Stockage Local).
- **Repositories**: `lib/data/repositories/prospect_repository_impl.dart`
- **DataSources**: Géré actuellement via `MySQLService`.

### 3. Présentation (Presentation)
Cette couche contient l'UI et la logique d'état.
- **Providers**: Utilisent les interfaces des repositories (via injection) pour manipuler les données.
- **Screens/Widgets**: Écoutent les Providers pour mettre à jour l'interface.

---

## 💉 Injection de Dépendances (Service Locator)

Nous utilisons un **Service Locator** (`sl`) centralisé dans `lib/core/di/service_locator.dart`.
Toutes les dépendances (Services, Repositories) sont initialisées au démarrage (`main.dart`) et injectées dans les Providers.

**Exemple d'accès:**
```dart
final repository = sl.prospectRepository;
```

---

## 🔒 Sécurité des Données

- **Requêtes SQL**: Toutes les requêtes sont centralisées dans `lib/core/constants/sql_queries.dart` et utilisent des requêtes préparées (`?`).
- **Validation**: Une liste blanche (White-listing) est appliquée dans les dépôts pour empêcher l'injection de colonnes non autorisées lors des mises à jour.
- **Identifiants**: Les mots de passe de base de données sont stockés de manière chiffrée via `SecureStorageService`.

---

## 🚀 Évolutivité

Grâce au **Repository Pattern**, pour remplacer la connexion MySQL directe par une API REST, il suffit de :
1. Créer une nouvelle implémentation dans `lib/data/repositories/`.
2. Mettre à jour le `ServiceLocator` pour pointer vers la nouvelle implémentation.
3. Aucun changement ne sera nécessaire dans les Providers ou la couche UI.

---

## 📊 Gestion d'État

Le projet utilise **Provider** pour la gestion d'état réactive.
- Chaque entité majeure (Prospect, Auth, Stats) possède son propre `ChangeNotifier`.
- Les écrans utilisent `Consumer` ou `context.watch()` pour réagir aux changements.
