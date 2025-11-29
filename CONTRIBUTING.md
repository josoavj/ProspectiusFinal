# Guide de Contribution - Prospectius

Merci de votre intérêt pour contribuer à Prospectius! Ce guide explique comment contribuer efficacement au projet.

## 🎯 Avant de Commencer

### Configurer l'Environnement de Développement

1. **Cloner le dépôt:**
   ```bash
   git clone <repository-url>
   cd prospectius
   ```

2. **Installer les dépendances:**
   ```bash
   bash scripts/setup.sh
   # Ou manuellement:
   flutter pub get
   ```

3. **Valider l'installation:**
   ```bash
   bash scripts/validate.sh
   ```

4. **Lancer l'app en mode debug:**
   ```bash
   flutter run
   ```

---

## 🔄 Workflow de Contribution

### 1. Créer une Issue

Avant de commencer, créez une issue pour discuter de:
- **Bugs:** Décrire le comportement inattendu
- **Features:** Expliquer la nouvelle fonctionnalité
- **Améliorations:** Proposer l'optimisation

**Format recommandé:**
```markdown
## Description
Brève description du problème/feature

## Context
Contexte additionnel

## Steps to Reproduce (si bug)
1. Étape 1
2. Étape 2
3. Étape 3

## Expected Behavior
Comportement attendu

## Actual Behavior
Comportement actuel

## Screenshots
Si applicable, ajouter des captures
```

### 2. Fork et Brancher

```bash
# Fork le repo sur GitHub

git clone https://github.com/votre-username/prospectius.git
cd prospectius

# Créer une branche descriptive
git checkout -b feature/description-courte
# ou
git checkout -b fix/bug-description
```

**Conventions de nommage:**
- `feature/user-authentication` - Nouvelle fonctionnalité
- `fix/database-connection-error` - Correction de bug
- `docs/installation-guide` - Documentation
- `refactor/service-layer` - Refactorisation
- `test/add-unit-tests` - Tests

### 3. Développer et Tester

**Format du code:**
```bash
# Formater le code Dart
dart format lib/ test/

# Analyser le code
dart analyze

# Linter Flutter
flutter analyze
```

**Standards de code:**
- Suivre les conventions Dart (PascalCase pour classes, camelCase pour variables)
- Documentez les fonctions publiques avec des commentaires `///`
- Maintenez une couverture de tests > 80%
- Pas de `print()` en production (utiliser `debugPrint()`)

**Exemple de code documenté:**
```dart
/// Authentifie un utilisateur avec les identifiants fournis.
///
/// Vérifie le couple [username]/[password] dans la base de données.
/// Retourne un [Account] si authentification réussie.
///
/// Throws [AuthException] si identifiants invalides
/// Throws [DatabaseException] si connexion échouée
Future<Account> authenticate(String username, String password) async {
  // Implementation
}
```

### 4. Tester

**Avant de soumettre:**
```bash
# Exécuter les tests
flutter test

# Tester sur les plateformes cibles
flutter run -d windows
flutter run -d linux

# Build de release (pour vérifier les avertissements)
flutter build windows --release
flutter build linux --release
```

**Ajouter des tests:**
- Créer `test/models/prospect_test.dart` pour les modèles
- Créer `test/services/database_service_test.dart` pour les services
- Créer `test/providers/auth_provider_test.dart` pour les providers

### 5. Committer

**Messages de commit clairs:**
```bash
# Feature
git commit -m "feat: add prospect search functionality

- Implement SearchProspectWidget
- Add search filtering in ProspectProvider
- Update tests for new search logic"

# Bug fix
git commit -m "fix: prevent null pointer in database connection

- Add null check before database access
- Add test case for empty database
- Update error handling in MySQLService"

# Docs
git commit -m "docs: update installation guide for Linux

- Add Ubuntu 22.04 specific instructions
- Clarify MariaDB setup process"
```

**Format:**
```
<type>: <subject>

<body>

<footer>
```

Types acceptés:
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation
- `style:` - Formatage sans changement de logique
- `refactor:` - Refactorisation sans changement externe
- `perf:` - Amélioration de performance
- `test:` - Ajout ou modification de tests

### 6. Push et Pull Request

```bash
git push origin feature/description-courte
```

**Template de Pull Request:**
```markdown
## Description
Courte description des changements

## Type de changement
- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Checklist
- [ ] Code suit les conventions du projet
- [ ] Tests ajoutés/mis à jour
- [ ] Documentation mise à jour
- [ ] Pas d'erreurs de linting
- [ ] Tests passent localement

## Screenshots/Videos
Si applicable, ajouter des démonstrations

## Issues Liées
Fixes #123
Related to #456
```

---

## 📐 Architecture du Projet

Respectez cette structure pour les nouveaux fichiers:

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   ├── account.dart             # Modèle utilisateur
│   ├── prospect.dart            # Modèle prospect
│   ├── interaction.dart         # Modèle interaction
│   └── stats.dart               # Modèle statistiques
├── services/
│   ├── mysql_service.dart       # Gestion connexion MySQL
│   ├── database_service.dart    # Opérations CRUD
│   └── storage_service.dart     # Stockage local
├── providers/
│   ├── auth_provider.dart       # Auth & configuration DB
│   ├── prospect_provider.dart   # Gestion prospects
│   └── stats_provider.dart      # Gestion statistiques
├── screens/
│   ├── database_config_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── prospects_screen.dart
│   ├── add_prospect_screen.dart
│   ├── prospect_detail_screen.dart
│   └── stats_screen.dart
└── widgets/                     # Widgets réutilisables
    └── custom_*.dart
```

**Ajouter une nouvelle feature:**

1. Créer le modèle: `lib/models/your_model.dart`
2. Ajouter au service: Méthode dans `database_service.dart`
3. Créer le provider: `lib/providers/your_provider.dart`
4. Créer l'écran: `lib/screens/your_screen.dart`
5. Ajouter les tests: `test/providers/your_provider_test.dart`

---

## 🧪 Tests

### Types de Tests à Ajouter

**Tests Unitaires:**
```dart
// test/models/prospect_test.dart
void main() {
  group('Prospect Model', () {
    test('creates prospect with valid data', () {
      final prospect = Prospect(
        id: 1,
        idCompte: 1,
        nom: 'Dupont',
        // ...
      );
      expect(prospect.nom, 'Dupont');
    });
  });
}
```

**Tests de Fournisseur:**
```dart
// test/providers/prospect_provider_test.dart
void main() {
  group('ProspectProvider', () {
    test('loads prospects successfully', () async {
      // Utiliser mockito pour mocker DatabaseService
    });
  });
}
```

### Exécuter les Tests

```bash
# Tous les tests
flutter test

# Fichier spécifique
flutter test test/models/prospect_test.dart

# Avec couverture
flutter test --coverage
```

---

## 📚 Documentation

### Ajouter de la Documentation

1. **Code inline:**
   ```dart
   /// Description courte
   /// 
   /// Description plus longue si nécessaire
   /// 
   /// Example:
   /// ```dart
   /// var result = myFunction(param);
   /// ```
   ```

2. **Fichiers README:**
   - Ajouter à `lib/services/README.md` si nouveau service
   - Ajouter à `lib/providers/README.md` si nouveau provider

3. **Mise à jour des guides:**
   - Mettre à jour `INSTALLATION.md` si changements de setup
   - Mettre à jour `ENVIRONMENT.md` si nouvelles variables

---

## 🚨 Checklist Avant Soumission

- [ ] Code formaté avec `dart format`
- [ ] `dart analyze` ne donne aucune erreur
- [ ] Tests ajoutés et tous passent (`flutter test`)
- [ ] Commit message clair et descriptif
- [ ] Description PR complète avec checklist
- [ ] Aucune dépendance non-essayée ajoutée
- [ ] Documentation mise à jour
- [ ] Pas de `TODO` oubliés
- [ ] Fonctionne sur Windows ET Linux
- [ ] Pas de breaking changes (ou bien documentés)

---

## 🤔 Questions?

1. Consultez la documentation dans `/docs`
2. Cherchez dans les [issues existantes](../../issues)
3. Créez une issue de discussion
4. Consultez les commentaires du code existant

---

## 📋 Processus de Review

Les contributeurs doivent:
1. Passer la validation automatisée
2. Être approuvés par au moins 1 mainteneur
3. Pas de conflits avec la branche principale
4. Code doit suivre les standards du projet

---

## 🎉 Après Acceptation

Votre contribution sera:
- Mergée dans `main`
- Créditée dans les releases notes
- Incluse dans la version suivante

---

## 📞 Besoin d'Aide?

- Lisez [ARCHITECTURE.md](./ARCHITECTURE.md) pour la structure
- Consultez [README.md](./README.md) pour la vue d'ensemble
- Vérifiez [scripts/README.md](./scripts/README.md) pour le développement

Merci pour votre contribution! 🙏
