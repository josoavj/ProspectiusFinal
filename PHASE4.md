# Phase 4: Améliorations de Schéma et Audit

## Vue d'ensemble
Phase 4 ajoute des fonctionnalités cruciales pour la conformité, le débogage et la traçabilité :
- **Audit Logging**: Enregistrement de toutes les modifications
- **Soft Deletes**: Suppression logique au lieu de suppression physique
- **Transfer History**: Suivi des changements de propriétaire de prospect
- **Migration Service**: Gestion versionnée du schéma de base de données

## Services Créés

### 1. MigrationService (`lib/services/migration_service.dart`)
Service de gestion des migrations de schéma BD versionnées.

**Fonctionnalités principales:**
- `initializeMigrationTable()` - Crée la table de suivi des migrations
- `runPendingMigrations()` - Exécute automatiquement les migrations en attente
- `addSoftDeleteToProspects()` - Ajoute colonne `deleted_at` aux prospects
- `addSoftDeleteToInteractions()` - Ajoute colonne `deleted_at` aux interactions
- `createAuditLogsTable()` - Crée table `audit_logs`
- `createTransferHistoryTable()` - Crée table `transfer_history`
- `addTrackingColumnsToProspects()` - Ajoute `created_by`, `updated_by`, timestamps

**Exécution automatique:**
- Les migrations s'exécutent automatiquement lors de la connexion BD dans `MySQLService.connect()`
- Idempotent: les migrations déjà appliquées ne sont pas réexécutées

### 2. AuditService (`lib/services/audit_service.dart`)
Service d'enregistrement d'audit pour la conformité et le debugging.

**Méthodes principales:**
```dart
Future<void> logAudit({
  required String tableName,
  required int recordId,
  required String action, // INSERT, UPDATE, DELETE
  required int userId,
  Map<String, dynamic>? oldValues,
  Map<String, dynamic>? newValues,
  String? description,
  String? ipAddress,
  String? userAgent,
})

Future<List<Map<String, dynamic>>> getAuditHistory(...)
Future<List<Map<String, dynamic>>> getUserAuditTrail(...)
Future<int> cleanupOldLogs(int daysOld)
```

**Appels intégrés:**
- `logProspectCreation()` - Enregistre création de prospect
- `logProspectUpdate()` - Enregistre modification avec changements détectés
- `logProspectDeletion()` - Enregistre suppression (soft delete)
- `logInteractionCreation()` - Enregistre nouvelle interaction
- `exportAuditLogs()` - Exporte en JSON pour analyse

### 3. TransferService (`lib/services/transfer_service.dart`)
Service de gestion de l'historique de transfert de prospects.

**Classes:**
- `ProspectTransfer` - Modèle représentant un transfert

**Méthodes principales:**
```dart
Future<ProspectTransfer> createTransfer({
  required int prospectId,
  required int fromUserId,
  required int toUserId,
  String? reason,
  String? notes,
})

Future<List<ProspectTransfer>> getProspectTransferHistory(int prospectId)
Future<List<ProspectTransfer>> getReceivedTransfers(int userId)
Future<List<ProspectTransfer>> getSentTransfers(int userId)
Future<int?> getCurrentProspectOwner(int prospectId)
Future<Map<String, dynamic>> getTransferStats(int userId)
Future<List<Map<String, dynamic>>> getTransferReport({...})
```

## Providers et Notifiers

### AuditNotifier (`lib/providers/audit_provider.dart`)
Gère l'état d'audit avec `ChangeNotifier`.

```dart
class AuditNotifier extends ChangeNotifier {
  Future<void> loadAuditHistory(int prospectId)
}
```

### TransferNotifier
Gère l'état des transferts.

```dart
class TransferNotifier extends ChangeNotifier {
  Future<void> loadTransferHistory(int prospectId)
  Future<void> loadReceivedTransfers(int userId)
  Future<void> loadSentTransfers(int userId)
  Future<void> loadTransferStats(int userId)
  Future<void> createTransfer({...})
}
```

## Screens et Widgets

### AuditTransferScreen (`lib/screens/audit_transfer_screen.dart`)
Affiche deux onglets:

**Onglet "Historique d'audit":**
- Liste tous les événements d'audit d'un prospect
- Icons colorées: INSERT (vert), UPDATE (bleu), DELETE (rouge)
- Affiche description et timestamp

**Onglet "Transferts":**
- Liste tous les transferts du prospect
- Affiche de/à, raison, notes, statut
- Détails dans une ExpansionTile

### TransferStatsWidget (`lib/widgets/transfer_stats_widget.dart`)
Affiche les statistiques de transfert:
- Nombre de transferts reçus
- Nombre de transferts envoyés
- Nombre de prospects possédés

## Intégration dans ProspectProvider

Ajout de méthodes:

```dart
Future<bool> transferProspect({
  required int prospectId,
  required int fromUserId,
  required int toUserId,
  String? reason,
  String? notes,
})
```

Les suppressions enregistrent automatiquement un log d'audit.

## Tables BD Créées

### migrations
```sql
CREATE TABLE migrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### audit_logs
```sql
CREATE TABLE audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id INT NOT NULL,
  action VARCHAR(20) NOT NULL,
  user_id INT NOT NULL,
  old_values JSON,
  new_values JSON,
  change_description VARCHAR(500),
  ip_address VARCHAR(45),
  user_agent VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_table_record (table_name, record_id),
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at),
  INDEX idx_action (action)
)
```

### transfer_history
```sql
CREATE TABLE transfer_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  prospect_id INT NOT NULL,
  from_user_id INT NOT NULL,
  to_user_id INT NOT NULL,
  transfer_reason VARCHAR(255),
  transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transfer_notes TEXT,
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (prospect_id) REFERENCES prospects(id),
  FOREIGN KEY (from_user_id) REFERENCES users(id),
  FOREIGN KEY (to_user_id) REFERENCES users(id)
)
```

### Modifications apportées aux tables existantes
- `prospects`: Ajout de colonnes `deleted_at`, `created_by`, `updated_by`, `created_at`, `updated_at`
- `interactions`: Ajout de colonne `deleted_at`

## Navigation
Accessible via:
1. Menu de ProspectDetailScreen → "Audit et transferts"
2. Route nommée: `/audit_transfer?prospectId=<id>`
3. Intégré dans le MainScreen

## Statut de Compilation
✅ 0 erreurs | 42 avertissements (style/info)

## Prochaines étapes
1. Implémenter les triggers BD pour auto-populate audit logs
2. Ajouter les rapports d'audit exportables
3. Implémenter la restauration depuis soft deletes
4. Ajouter les statistiques d'audit au dashboard
