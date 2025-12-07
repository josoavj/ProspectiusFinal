import 'package:mysql1/mysql1.dart' as mysql;
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

/// Représente un transfert de prospect
class ProspectTransfer {
  final int? id;
  final int prospectId;
  final int fromUserId;
  final int toUserId;
  final String? transferReason;
  final DateTime? transferDate;
  final String? transferNotes;
  final String status;

  ProspectTransfer({
    this.id,
    required this.prospectId,
    required this.fromUserId,
    required this.toUserId,
    this.transferReason,
    this.transferDate,
    this.transferNotes,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'prospect_id': prospectId,
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'transfer_reason': transferReason,
        'transfer_date': transferDate?.toIso8601String(),
        'transfer_notes': transferNotes,
        'status': status,
      };
}

/// Service de gestion de l'historique de transfert de prospects
/// Permet de suivre tous les changements de propriétaire de prospect
class TransferService {
  final mysql.MySqlConnection _connection;

  TransferService(this._connection);

  /// Enregistre un transfert de prospect
  Future<ProspectTransfer> createTransfer({
    required int prospectId,
    required int fromUserId,
    required int toUserId,
    String? reason,
    String? notes,
  }) async {
    try {
      if (prospectId == 0 || fromUserId == 0 || toUserId == 0) {
        throw ValidationException(message: 'IDs invalides pour le transfert');
      }

      final result = await _connection.query(
        '''
        INSERT INTO TransferHistory 
        (id_prospect, from_user_id, to_user_id, transfer_reason, transfer_notes)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [prospectId, fromUserId, toUserId, reason, notes],
      );

      final transferId = result.insertId;

      AppLogger.success(
          'Transfert enregistré: prospect#$prospectId de user#$fromUserId à user#$toUserId');

      return ProspectTransfer(
        id: transferId,
        prospectId: prospectId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        transferReason: reason,
        transferDate: DateTime.now(),
        transferNotes: notes,
        status: 'completed',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du transfert', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère l'historique de transfert d'un prospect
  Future<List<ProspectTransfer>> getProspectTransferHistory(
      int prospectId) async {
    try {
      final results = await _connection.query(
        '''
        SELECT id, id_prospect, from_user_id, to_user_id, transfer_reason, 
               transfer_date, transfer_notes, status
        FROM TransferHistory
        WHERE id_prospect = ?
        ORDER BY transfer_date DESC
        ''',
        [prospectId],
      );

      return results
          .map((row) => ProspectTransfer(
                id: row[0],
                prospectId: row[1],
                fromUserId: row[2],
                toUserId: row[3],
                transferReason: row[4],
                transferDate: row[5] != null ? DateTime.parse(row[5]) : null,
                transferNotes: row[6],
                status: row[7],
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération de l\'historique de transfert',
          e,
          stackTrace);
      return [];
    }
  }

  /// Récupère l'historique de transfert reçu par un utilisateur
  Future<List<ProspectTransfer>> getReceivedTransfers(
    int userId, {
    int limit = 100,
  }) async {
    try {
      final results = await _connection.query(
        '''
        SELECT id, id_prospect, from_user_id, to_user_id, transfer_reason, 
               transfer_date, transfer_notes, status
        FROM TransferHistory
        WHERE to_user_id = ?
        ORDER BY transfer_date DESC
        LIMIT ?
        ''',
        [userId, limit],
      );

      return results
          .map((row) => ProspectTransfer(
                id: row[0],
                prospectId: row[1],
                fromUserId: row[2],
                toUserId: row[3],
                transferReason: row[4],
                transferDate: row[5] != null ? DateTime.parse(row[5]) : null,
                transferNotes: row[6],
                status: row[7],
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des transferts reçus', e, stackTrace);
      return [];
    }
  }

  /// Récupère l'historique de transfert envoyé par un utilisateur
  Future<List<ProspectTransfer>> getSentTransfers(
    int userId, {
    int limit = 100,
  }) async {
    try {
      final results = await _connection.query(
        '''
        SELECT id, id_prospect, from_user_id, to_user_id, transfer_reason, 
               transfer_date, transfer_notes, status
        FROM TransferHistory
        WHERE from_user_id = ?
        ORDER BY transfer_date DESC
        LIMIT ?
        ''',
        [userId, limit],
      );

      return results
          .map((row) => ProspectTransfer(
                id: row[0],
                prospectId: row[1],
                fromUserId: row[2],
                toUserId: row[3],
                transferReason: row[4],
                transferDate: row[5] != null ? DateTime.parse(row[5]) : null,
                transferNotes: row[6],
                status: row[7],
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la récupération des transferts envoyés',
          e, stackTrace);
      return [];
    }
  }

  /// Récupère le propriétaire actuel d'un prospect
  Future<int?> getCurrentProspectOwner(int prospectId) async {
    try {
      // Chercher le dernier transfert
      final transferResult = await _connection.query(
        '''
        SELECT to_user_id FROM TransferHistory
        WHERE id_prospect = ?
        ORDER BY transfer_date DESC
        LIMIT 1
        ''',
        [prospectId],
      );

      if (transferResult.isNotEmpty) {
        return transferResult.first[0];
      }

      // Si pas de transfert, récupérer l'assignation actuelle du prospect
      final prospectResult = await _connection.query(
        'SELECT assignation FROM Prospect WHERE id_prospect = ?',
        [prospectId],
      );

      if (prospectResult.isNotEmpty) {
        return prospectResult.first[0];
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération du propriétaire du prospect',
          e,
          stackTrace);
      return null;
    }
  }

  /// Calcule les statistiques de transfert pour un utilisateur
  Future<Map<String, dynamic>> getTransferStats(int userId) async {
    try {
      // Transferts reçus
      final receivedResult = await _connection.query(
        'SELECT COUNT(*) FROM TransferHistory WHERE to_user_id = ?',
        [userId],
      );
      final received = receivedResult.first[0] ?? 0;

      // Transferts envoyés
      final sentResult = await _connection.query(
        'SELECT COUNT(*) FROM TransferHistory WHERE from_user_id = ?',
        [userId],
      );
      final sent = sentResult.first[0] ?? 0;

      // Prospects actuellement possédés
      final ownedResult = await _connection.query(
        '''
        SELECT COUNT(DISTINCT p.id_prospect) FROM Prospect p
        LEFT JOIN TransferHistory t ON p.id_prospect = t.id_prospect
        WHERE p.assignation = ? OR (
          SELECT MAX(transfer_date) FROM TransferHistory
          WHERE id_prospect = p.id_prospect AND to_user_id = ?
        ) IS NOT NULL
        ''',
        [userId, userId],
      );
      final owned = ownedResult.first[0] ?? 0;

      return {
        'received': received,
        'sent': sent,
        'owned': owned,
        'total_movements': received + sent,
      };
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors du calcul des statistiques de transfert', e, stackTrace);
      return {
        'received': 0,
        'sent': 0,
        'owned': 0,
        'total_movements': 0,
      };
    }
  }

  /// Génère un rapport de transfert sur une période
  Future<List<Map<String, dynamic>>> getTransferReport({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
  }) async {
    try {
      String query = '''
        SELECT 
          t.id, p.nomp as prospect_lastname, p.prenomp as prospect_firstname,
          u1.nom as from_lastname, u1.prenom as from_firstname,
          u2.nom as to_lastname, u2.prenom as to_firstname,
          t.transfer_reason, t.transfer_date
        FROM TransferHistory t
        JOIN Prospect p ON t.id_prospect = p.id_prospect
        JOIN Account u1 ON t.from_user_id = u1.id_compte
        JOIN Account u2 ON t.to_user_id = u2.id_compte
        WHERE 1=1
      ''';

      final params = <dynamic>[];

      if (startDate != null) {
        query += ' AND t.transfer_date >= ?';
        params.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        query += ' AND t.transfer_date <= ?';
        params.add(endDate.toIso8601String());
      }

      if (userId != null) {
        query += ' AND (t.from_user_id = ? OR t.to_user_id = ?)';
        params.addAll([userId, userId]);
      }

      query += ' ORDER BY t.transfer_date DESC';

      final results = await _connection.query(query, params);

      return results
          .map((row) => {
                'id': row[0],
                'prospect_name': '${row[2]} ${row[1]}',
                'from_user': '${row[4]} ${row[3]}',
                'to_user': '${row[6]} ${row[5]}',
                'reason': row[7],
                'date': row[8].toString(),
              })
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la génération du rapport de transfert', e,
          stackTrace);
      return [];
    }
  }
}
