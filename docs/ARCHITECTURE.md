# Dans les coulisses de Prospectius : Notre Architecture

Ce document explique comment Prospectius est construit. Pour garantir que l'application reste rapide, fiable et facile à faire évoluer, nous avons choisi une organisation structurée appelée **Clean Architecture**.

---

## L'organisation en couches

Imaginez Prospectius comme un restaurant bien organisé :

### La Salle (Présentation) - `lib/presentation`

C'est ce que vous voyez : le menu, les tables, la décoration. Dans l'application, ce sont les **Écrans** et les **Widgets**. Ils s'occupent d'afficher les données joliment et de réagir à vos clics.

- **Le Maître d'Hôtel (Provider)** : Il fait le lien entre la salle et la cuisine. Il sait quel écran a besoin de quelle information.

### Les Recettes (Domaine) - `lib/domain`

C'est le savoir-faire de l'application. Ici, on définit **ce que l'on peut faire** (créer un prospect, changer un statut) sans se soucier de savoir où sont stockées les données. C'est le cœur intelligent de Prospectius.

### 🍳 La Cuisine (Données) - `lib/data`

C'est ici que l'on prépare réellement les plats. Cette couche s'occupe d'aller chercher les informations dans votre base de données **MySQL** ou dans les fichiers locaux. Elle transforme les données brutes en informations utilisables par l'application.

---

## Pourquoi ce choix ?

Cette organisation nous offre trois avantages majeurs :

1. **Facilité d'entretien** : Si nous changeons la décoration (le design), la cuisine (la base de données) ne change pas.
2. **Évolutivité** : Demain, si nous voulons que Prospectius fonctionne avec un serveur dans le cloud plutôt que MySQL local, il nous suffira de changer une seule pièce du puzzle.
3. **Sécurité maximale** : Chaque couche a un rôle précis, ce qui limite les risques d'erreurs et facilite la protection de vos données.

---

## Protection et Confidentialité

- **Échanges sécurisés** : Toutes les discussions avec votre base de données utilisent des "requêtes préparées". C'est un blindage qui empêche toute intrusion malveillante.
- **Coffre-fort numérique** : Vos mots de passe de connexion ne sont jamais affichés en clair. Ils sont stockés dans un espace ultra-sécurisé de votre ordinateur.
- **Tri sélectif** : L'application vérifie chaque donnée que vous saisissez pour s'assurer qu'elle est au bon format avant de l'enregistrer.

---

*Prospectius : Une base solide pour une croissance sereine. APEXNova Labs © 2025*
