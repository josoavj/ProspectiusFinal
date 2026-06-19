# 🛡️ Politique de Sécurité - Prospectius

**Dernière révision:** 4 décembre 2025  
**Version:** 1.1.0 (Architecture Sécurisée)  
**Statut Global:** ✅ **SÉCURISÉ POUR USAGE PROFESSIONNEL (LAN/VPN)**

---

## 📊 Résumé Exécutif

Cette revue confirme que Prospectius v1.1.0 intègre les standards de sécurité modernes pour la protection des données CRM :

- ✅ **Protection Intégrale** contre les injections SQL (Prepared Statements + White-listing).
- ✅ **Chiffrement au Repos** des identifiants de connexion (Secure Storage).
- ✅ **Hachage Robuste** des mots de passe (BCrypt).
- ✅ **Contrôle d'Accès** basé sur l'assignation (RBAC).
- ✅ **Limitation de Débit** (Rate Limiting) sur l'authentification.

---

## 🛡️ Piliers de Sécurité Implémentés

### 1. Protection des Identifiants (Secure Storage) ✅
Les informations sensibles (mot de passe de la base de données) ne sont plus stockées en texte clair.
- **Technologie:** `FlutterSecureStorage` (Keychain pour iOS/macOS, Keystore pour Android).
- **Avantage:** Même avec un accès physique au système de fichiers, les credentials restent illisibles.

### 2. Défense Contre les Injections SQL ✅
Une double couche de protection est désormais active :
- **Requêtes Préparées:** Utilisation systématique de paramètres `?` via `SqlQueries`.
- **Liste Blanche (White-listing):** Le dépôt (`ProspectRepository`) filtre strictement les colonnes autorisées lors des mises à jour, empêchant toute manipulation de la structure de la base par l'utilisateur.

### 3. Sécurité des Mots de Passe ✅
- **Algorithme:** BCrypt avec sel automatique.
- **Résistance:** Protection native contre les attaques par dictionnaire et les tables arc-en-ciel.

### 4. Contrôle d'Accès et Isolation (RBAC) ✅
L'architecture en couches (Clean Architecture) impose une isolation stricte des données :
- Chaque requête SQL est filtrée par l'ID de l'utilisateur authentifié (`assignation = ?`).
- Un utilisateur ne peut ni voir, ni modifier les prospects d'un autre collaborateur.

### 5. Protection Anti-Force Brute ✅
- **Mécanisme:** `RateLimitService`.
- **Action:** Verrouillage temporaire du compte après plusieurs tentatives infructueuses pour ralentir les attaques automatisées.

### 6. Audit et Traçabilité ✅
- **Logging:** Système de journaux quotidiens chiffrés et isolés dans le dossier utilisateur.
- **Audit Trail:** Historique complet des interactions et des modifications par prospect.

---

## 🌐 Scénarios d'Usage et Exigences

### Scenario 1: Usage Local ou LAN (Recommandé) ✅
*Client Prospectius ↔ Serveur MariaDB (Même réseau ou VPN)*
- **Statut:** SÉCURISÉ.
- **Configuration:** Firewall port 3306 restreint aux IPs autorisées.

### Scenario 2: Usage Réseau Public / Internet ⚠️
*Client Prospectius ↔ Serveur MariaDB distant*
- **Exigence Critique:** L'activation du SSL/TLS est impérative pour chiffrer le flux réseau entre l'application et le serveur.
- **Recommandation:** Utiliser un tunnel SSH ou un VPN pour une sécurité maximale.

---

## 📋 Checklist de Conformité

- [x] Chiffrement des identifiants (AES/KeyStore)
- [x] Hachage BCrypt des mots de passe
- [x] Requêtes SQL paramétrées (Anti-SQLi)
- [x] Filtrage par liste blanche des colonnes
- [x] Isolation des données par utilisateur
- [x] Rate limiting actif
- [x] Système de logs d'audit
- [x] Gestion sécurisée des erreurs (pas de fuite d'info technique)

---

## 📊 Score de Sécurité Global

| Aspect | Score | Statut |
|:--- |:--- |:--- |
| **Stockage des données** | 9/10 | ✅ Excellent (Secure Storage) |
| **Intégrité SQL** | 10/10 | ✅ Blindé (White-listing) |
| **Authentification** | 8/10 | ✅ Robuste (BCrypt + Rate Limit) |
| **Autorisation** | 9/10 | ✅ Précis (RBAC Repository) |
| **Confidentialité Réseau** | 6/10 | ⚠️ Dépend de la config SSL |
| **GLOBAL** | **8.4/10** | **✅ HAUT NIVEAU DE SÉCURITÉ** |

---

## 📞 Rapporter une Vulnérabilité

Si vous découvrez une faille de sécurité :
1. Contactez : josoavonjiniaina13@gmail.com
2. Ne publiez pas l'information avant résolution.
3. Nous nous engageons à répondre sous 48h.

---
*Document généré par le système d'audit Prospectius - Décembre 2025*
