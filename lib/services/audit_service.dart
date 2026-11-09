import 'package:mysql1/mysql1.dart' as mysql;
import 'dart:convert';
import '../utils/app_logger.dart';

/// Service de gestion des journaux d'audit
/// Enregistre toutes les modifications pour la conformité et le debugging
class AuditService {
  final mysql.MySqlConnection _connection;

  AuditService(this._connection);

  /// Enregistre une opération d'audit
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
  }) async {
    try {
      await _connection.query(
        '''
        INSERT INTO audit_logs 
        (table_name, record_id, action, user_id, old_values, new_values, 
         change_description, ip_address, user_agent)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          tableName,
          recordId,
          action,
          userId,
          oldValues != null ? jsonEncode(oldValues) : null,
          newValues != null ? jsonEncode(newValues) : null,
          description,
          ipAddress,
          userAgent,
        ],
      );

      AppLogger.info('Audit enregistré: $action sur $tableName#$recordId');
    } catch (e) {
      AppLogger.warning('Erreur lors de l\'enregistrement de l\'audit: $e');
      // Ne pas lancer d'exception pour ne pas bloquer les opérations
    }
  }

  /// Enregistre une création de prospect
  Future<void> logProspectCreation({
    required int prospectId,
    required int userId,
    required Map<String, dynamic> prospectData,
  }) async {
    await logAudit(
      tableName: 'Prospect',
      recordId: prospectId,
      action: 'INSERT',
      userId: userId,
      newValues: prospectData,
      description: 'Nouveau prospect créé',
    );
  }

  /// Enregistre une modification de prospect
  Future<void> logProspectUpdate({
    required int prospectId,
    required int userId,
    required Map<String, dynamic> oldValues,
    required Map<String, dynamic> newValues,
  }) async {
    // Détecter les changements
    final changes = <String>[];
    newValues.forEach((key, newValue) {
      final oldValue = oldValues[key];
      if (oldValue != newValue) {
        changes.add('$key: $oldValue → $newValue');
      }
    });

    await logAudit(
      tableName: 'Prospect',
      recordId: prospectId,
      action: 'UPDATE',
      userId: userId,
      oldValues: oldValues,
      newValues: newValues,
      description: 'Prospect modifié: ${changes.join(', ')}',
    );
  }

  /// Enregistre une suppression (soft delete) de prospect
  Future<void> logProspectDeletion({
    required int prospectId,
    required int userId,
  }) async {
    await logAudit(
      tableName: 'Prospect',
      recordId: prospectId,
      action: 'DELETE',
      userId: userId,
      description: 'Prospect supprimé (soft delete)',
    );
  }

  /// Enregistre une interaction créée
  Future<void> logInteractionCreation({
    required int interactionId,
    required int prospectId,
    required int userId,
    required Map<String, dynamic> interactionData,
  }) async {
    await logAudit(
      tableName: 'Interaction',
      recordId: interactionId,
      action: 'INSERT',
      userId: userId,
      newValues: interactionData,
      description: 'Interaction créée pour prospect#$prospectId',
    );
  }

  /// Récupère l'historique d'audit pour une table/enregistrement
  Future<List<Map<String, dynamic>>> getAuditHistory({
    required String tableName,
    required int recordId,
    int limit = 100,
  }) async {
    try {
      final results = await _connection.query(
        '''
        SELECT id, action, user_id, change_description, created_at
        FROM audit_logs
        WHERE table_name = ? AND record_id = ?
        ORDER BY created_at DESC
        LIMIT ?
        ''',
        [tableName, recordId, limit],
      );

      return results
          .map((row) => {
                'id': row[0],
                'action': row[1],
                'user_id': row[2],
                'description': row[3],
                'created_at': row[4].toString(),
              })
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération de l\'historique d\'audit',
          e,
          stackTrace);
      return [];
    }
  }

  /// Récupère tous les audits d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserAuditTrail({
    required int userId,
    int limit = 100,
  }) async {
    try {
      final results = await _connection.query(
        '''
        SELECT table_name, record_id, action, change_description, created_at
        FROM audit_logs
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT ?
        ''',
        [userId, limit],
      );

      return results
          .map((row) => {
                'table_name': row[0],
                'record_id': row[1],
                'action': row[2],
                'description': row[3],
                'created_at': row[4].toString(),
              })
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération du trail d\'audit utilisateur',
          e,
          stackTrace);
      return [];
    }
  }

  /// Exporte les logs d'audit en JSON
  Future<String> exportAuditLogs({
    required String tableName,
    required int recordId,
  }) async {
    try {
      final history = await getAuditHistory(
        tableName: tableName,
        recordId: recordId,
        limit: 1000,
      );

      return jsonEncode({
        'table_name': tableName,
        'record_id': recordId,
        'export_date': DateTime.now().toIso8601String(),
        'entries': history,
      });
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'export des logs d\'audit', e, stackTrace);
      rethrow;
    }
  }

  /// Nettoie les logs d'audit anciens (plus de N jours)
  Future<int> cleanupOldLogs(int daysOld) async {
    try {
      final result = await _connection.query(
        '''
        DELETE FROM audit_logs
        WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
        ''',
        [daysOld],
      );

      final affectedRows = result.affectedRows;
      AppLogger.info(
          'Nettoyage: $affectedRows logs d\'audit anciens supprimés');

      return affectedRows;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors du nettoyage des logs d\'audit', e, stackTrace);
      return 0;
    }
  }
}
