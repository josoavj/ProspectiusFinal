import 'package:mysql1/mysql1.dart' as mysql;
import 'dart:async';
import '../utils/app_logger.dart';

/// Service de gestion des migrations de schéma BD
/// Permet d'appliquer des changements au schéma de manière versionnée et sûre
class MigrationService {
  final mysql.MySqlConnection _connection;

  MigrationService(this._connection);

  /// Crée la table de suivi des migrations si elle n'existe pas
  Future<void> initializeMigrationTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS migrations (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL UNIQUE,
          applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_name (name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table migrations initialisée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'initialisation de la table migrations',
          e, stackTrace);
      rethrow;
    }
  }

  /// Récupère la liste des migrations déjà appliquées
  Future<List<String>> getAppliedMigrations() async {
    try {
      final results = await _connection.query('''
        SELECT name FROM migrations ORDER BY applied_at;
      ''');

      return results.map((row) => row[0].toString()).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des migrations', e, stackTrace);
      return [];
    }
  }

  /// Enregistre une migration comme appliquée
  Future<void> recordMigration(String name) async {
    try {
      await _connection.query(
        'INSERT INTO migrations (name) VALUES (?)',
        [name],
      );
      AppLogger.success('Migration enregistrée: $name');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'enregistrement de la migration', e, stackTrace);
      rethrow;
    }
  }

  /// Ajoute une colonne deleted_at pour soft delete
  Future<void> addSoftDeleteToProspects() async {
    const migrationName = 'add_soft_delete_to_prospects';

    try {
      final applied = await getAppliedMigrations();
      if (applied.contains(migrationName)) {
        AppLogger.info('Migration $migrationName déjà appliquée');
        return;
      }

      await _connection.query('''
        ALTER TABLE Prospect
        ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL,
        ADD INDEX idx_deleted_at (deleted_at);
      ''');

      await recordMigration(migrationName);
      AppLogger.success('Soft delete ajouté à la table Prospect');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'ajout du soft delete', e, stackTrace);
      rethrow;
    }
  }

  /// Ajoute une colonne deleted_at pour les interactions
  Future<void> addSoftDeleteToInteractions() async {
    const migrationName = 'add_soft_delete_to_interactions';

    try {
      final applied = await getAppliedMigrations();
      if (applied.contains(migrationName)) {
        AppLogger.info('Migration $migrationName déjà appliquée');
        return;
      }

      await _connection.query('''
        ALTER TABLE interaction
        ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL,
        ADD INDEX idx_deleted_at (deleted_at);
      ''');

      await recordMigration(migrationName);
      AppLogger.success('Soft delete ajouté à la table interactions');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'ajout du soft delete aux interactions',
          e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table d'audit logging
  Future<void> createAuditLogsTable() async {
    const migrationName = 'create_audit_logs_table';

    try {
      final applied = await getAppliedMigrations();
      if (applied.contains(migrationName)) {
        AppLogger.info('Migration $migrationName déjà appliquée');
        return;
      }

      await _connection.query('''
        CREATE TABLE IF NOT EXISTS audit_logs (
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
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');

      await recordMigration(migrationName);
      AppLogger.success('Table audit_logs créée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table audit_logs', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table de transfer history
  Future<void> createTransferHistoryTable() async {
    const migrationName = 'create_transfer_history_table';

    try {
      final applied = await getAppliedMigrations();
      if (applied.contains(migrationName)) {
        AppLogger.info('Migration $migrationName déjà appliquée');
        return;
      }

      await _connection.query('''
        CREATE TABLE IF NOT EXISTS transfer_history (
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
          FOREIGN KEY (prospect_id) REFERENCES prospects(id) ON DELETE CASCADE,
          FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE RESTRICT,
          FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE RESTRICT,
          INDEX idx_prospect_id (prospect_id),
          INDEX idx_transfer_date (transfer_date),
          INDEX idx_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');

      await recordMigration(migrationName);
      AppLogger.success('Table transfer_history créée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table transfer_history',
          e, stackTrace);
      rethrow;
    }
  }

  /// Ajoute les colonnes de tracking (created_by, updated_by, created_at, updated_at)
  Future<void> addTrackingColumnsToProspects() async {
    const migrationName = 'add_tracking_columns_to_prospects';

    try {
      final applied = await getAppliedMigrations();
      if (applied.contains(migrationName)) {
        AppLogger.info('Migration $migrationName déjà appliquée');
        return;
      }

      await _connection.query('''
        ALTER TABLE prospect
        ADD COLUMN created_by INT,
        ADD COLUMN updated_by INT,
        ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        ADD FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
        ADD FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
        ADD INDEX idx_created_by (created_by),
        ADD INDEX idx_updated_by (updated_by);
      ''');

      await recordMigration(migrationName);
      AppLogger.success('Tracking columns ajoutées à la table prospects');
    } catch (e, stackTrace) {
      if (e.toString().contains('Duplicate column') ||
          e.toString().contains('already exists')) {
        AppLogger.warning(
            'Les colonnes de tracking existent déjà ou ont d\'autres colonnes');
        await recordMigration(migrationName);
      } else {
        AppLogger.error(
            'Erreur lors de l\'ajout des tracking columns', e, stackTrace);
        rethrow;
      }
    }
  }

  /// Exécute toutes les migrations en attente
  Future<void> runPendingMigrations() async {
    try {
      AppLogger.info('Vérification des migrations en attente...');

      await initializeMigrationTable();
      await addSoftDeleteToProspects();
      await addSoftDeleteToInteractions();
      await createAuditLogsTable();
      await createTransferHistoryTable();
      await addTrackingColumnsToProspects();

      AppLogger.success('Toutes les migrations ont été exécutées');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'exécution des migrations', e, stackTrace);
      rethrow;
    }
  }

  /// Rollback d'une migration spécifique
  Future<void> rollbackMigration(String migrationName) async {
    try {
      await _connection.query(
        'DELETE FROM migrations WHERE name = ?',
        [migrationName],
      );
      AppLogger.success('Migration $migrationName rollback enregistrée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors du rollback de la migration', e, stackTrace);
      rethrow;
    }
  }
}
