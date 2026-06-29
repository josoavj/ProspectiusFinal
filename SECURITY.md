# Politique de Sécurité - Prospectius

**Dernière révision :** 5 décembre 2025  
**Version :** 1.2.0 (Intégrité et Performance)  
**Statut Global :** Certifié pour usage professionnel (LAN/VPN)

---

## Résumé Exécutif

L'architecture de Prospectius v1.2.0 repose sur des standards de sécurité industriels garantissant la confidentialité, l'intégrité et la disponibilité des données CRM. Cette version introduit des mécanismes avancés de protection contre la perte de données et une optimisation des performances réduisant les vecteurs d'attaque par déni de service.

### Mesures principales
- Protection systématique contre les injections SQL via requêtes préparées.
- Chiffrement des identifiants au repos (Secure Storage).
- Hachage cryptographique des mots de passe (BCrypt).
- Contrôle d'accès basé sur les rôles et l'assignation (RBAC).
- Intégrité renforcée par la suppression logique (Soft Deletes).
- Validation stricte des entrées par liste blanche.

---

## Piliers de Sécurité Implémentés

### 1. Protection des Identifiants (Secure Storage)
Les secrets de connexion (mots de passe de base de données, jetons) sont stockés dans les enclaves sécurisées du système :
- **iOS/macOS :** Keychain.
- **Android :** Keystore (chiffrement matériel).
- **Conséquence :** Les données restent chiffrées même en cas d'accès physique au stockage de l'appareil.

### 2. Sécurité de la Couche de Données
- **Requêtes Paramétrées :** Aucune concaténation de chaînes n'est autorisée. L'utilisation du service `SqlQueries` assure que les entrées utilisateurs sont traitées comme des données et non comme du code exécutable.
- **Liste Blanche (White-listing) :** Le dépôt `ProspectRepository` filtre les colonnes autorisées lors des opérations d'écriture, interdisant toute modification non sollicitée de la structure de la table.
- **Intégrité des données :** L'implémentation des "Soft Deletes" permet de marquer les données comme supprimées sans retrait physique immédiat, offrant une protection contre les erreurs humaines et une traçabilité pour les audits.

### 3. Authentification et Autorisation
- **Hachage :** Utilisation de BCrypt avec sel unique par utilisateur, rendant les attaques par tables arc-en-ciel inefficaces.
- **Isolation (RBAC) :** Chaque utilisateur est strictement limité aux prospects qui lui sont assignés. La couche Repository injecte systématiquement l'ID de l'utilisateur authentifié dans les clauses WHERE.
- **Protection Anti-Force Brute :** Le `RateLimitService` bloque temporairement les tentatives de connexion après plusieurs échecs consécutifs.

### 4. Disponibilité et Performance
- **Indexation :** Des index composites optimisés réduisent la charge processeur du serveur de base de données, limitant les risques de saturation lors de recherches intensives.
- **Mise en cache :** Le `CacheService` réduit la latence et le nombre de requêtes sortantes, protégeant ainsi l'infrastructure contre les pics de charge.

---

## Scénarios d'Usage et Exigences

### Usage LAN / VPN (Standard)
*Flux : Client Prospectius ↔ Serveur MariaDB/MySQL*
- Configuration recommandée pour une sécurité optimale.
- Firewall : Port 3306 restreint aux segments réseau autorisés.

### Usage sur Réseau Public (Internet)
- **Exigence :** L'activation du protocole SSL/TLS est obligatoire pour le transport des données.
- **Recommandation :** Utilisation d'un tunnel SSH ou d'un VPN pour masquer l'infrastructure.

---

## Audit et Conformité

- [x] Chiffrement AES/KeyStore des credentials
- [x] Hachage BCrypt (mots de passe)
- [x] Requêtes SQL paramétrées (Anti-SQLi)
- [x] Liste blanche des colonnes (Repository)
- [x] Soft Deletes (Intégrité des données)
- [x] Isolation des données par utilisateur (RBAC)
- [x] Protection contre le brute-force (Rate limiting)
- [x] Logs d'audit et historique des transferts
- [x] Suite de tests de sécurité automatisée

---

## Rapporter une Vulnérabilité

Pour signaler une faille de sécurité, merci de contacter exclusivement :  
**josoavonjiniaina13@gmail.com**

Nous nous engageons à analyser et répondre à tout signalement sous 48 heures. Nous demandons de respecter le principe de divulgation responsable en ne publiant aucune information technique avant la mise à disposition d'un correctif.

---
*Document généré par le système d'audit Prospectius - Décembre 2025*
