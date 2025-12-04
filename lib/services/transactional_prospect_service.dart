import 'transaction_service.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

/// Service d'exemple pour démontrer l'utilisation des transactions
/// et du verrouillage optimiste/pessimiste
class TransactionalProspectService {
  final TransactionService _transactionService = TransactionService();

  /// Met à jour le statut d'un prospect de manière atomique avec historique
  ///
  /// Cette opération est atomique:
  /// 1. Vérrouille le prospect
  /// 2. Modifie le statut
  /// 3. Enregistre l'historique
  /// 4. Ou tout échoue et rollback
  ///
  /// Cela évite les race conditions où deux vendeurs modifient simultanément
  Future<void> updateProspectStatusAtomic(
    int prospectId,
    String newStatus,
    int userId,
  ) async {
    try {
      AppLogger.info(
          'Mise à jour du statut du prospect #$prospectId → $newStatus');

      await _transactionService.executeTransaction(
        (connection) async {
          // Étape 1: Récupérer et verrouiller le prospect
          final prospectResult = await connection.query(
            'SELECT id_prospect, status FROM Prospect WHERE id_prospect = ? FOR UPDATE',
            [prospectId],
          );

          if (prospectResult.isEmpty) {
            throw DatabaseException(
              message: 'Prospect #$prospectId non trouvé',
              code: 'NOT_FOUND',
            );
          }

          final oldStatus = prospectResult.first['status'] as String;

          // Étape 2: Mettre à jour le statut
          final updateResult = await connection.query(
            'UPDATE Prospect SET status = ?, date_update = NOW() WHERE id_prospect = ?',
            [newStatus, prospectId],
          );

          if (updateResult.affectedRows == 0) {
            throw DatabaseException(
              message: 'Échec de la mise à jour du prospect #$prospectId',
              code: 'UPDATE_FAILED',
            );
          }

          AppLogger.debug(
              'Prospect #$prospectId mis à jour: $oldStatus → $newStatus');

          // Étape 3: Enregistrer l'historique des changements
          await connection.query(
            '''INSERT INTO StatusHistory 
               (prospect_id, old_status, new_status, user_id, changed_at) 
               VALUES (?, ?, ?, ?, NOW())''',
            [prospectId, oldStatus, newStatus, userId],
          );

          AppLogger.debug('Historique de statut enregistré');

          // Si on arrive ici, tout s'est bien passé
          // La transaction sera automatiquement commitée
        },
      );

      AppLogger.success(
          'Prospect #$prospectId mis à jour avec succès: $newStatus');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la mise à jour du prospect #$prospectId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Ajoute une interaction et met à jour le compteur du prospect de manière atomique
  ///
  /// Évite les race conditions sur le compteur d'interactions
  Future<void> addInteractionAtomic(
    int prospectId,
    int userId,
    String description,
    String type,
  ) async {
    try {
      AppLogger.info('Ajout d\'interaction au prospect #$prospectId');

      await _transactionService.executeTransaction(
        (connection) async {
          // Étape 1: Insérer l'interaction
          await connection.query(
            '''INSERT INTO Interaction 
               (prospect_id, user_id, description, type, created_at) 
               VALUES (?, ?, ?, ?, NOW())''',
            [prospectId, userId, description, type],
          );

          AppLogger.debug('Interaction créée');

          // Étape 2: Incrémenter le compteur (atomique avec la transaction)
          final updateResult = await connection.query(
            'UPDATE Prospect SET interaction_count = interaction_count + 1, date_update = NOW() WHERE id_prospect = ?',
            [prospectId],
          );

          if (updateResult.affectedRows == 0) {
            throw DatabaseException(
              message:
                  'Impossible de mettre à jour le compteur du prospect #$prospectId',
              code: 'UPDATE_FAILED',
            );
          }

          AppLogger.debug('Compteur d\'interaction incrémenté');
        },
      );

      AppLogger.success(
          'Interaction ajoutée au prospect #$prospectId avec succès');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'ajout d\'interaction au prospect #$prospectId',
          e,
          stackTrace);
      rethrow;
    }
  }

  /// Transfère un prospect d'un vendeur à un autre de manière atomique
  ///
  /// Assure que:
  /// 1. Tous les enregistrements de l'historique sont à jour
  /// 2. Le prospect est assigné au nouveau vendeur
  /// 3. Aucune incohérence si crash pendant le transfert
  Future<void> transferProspectAtomic(
    int prospectId,
    int fromUserId,
    int toUserId,
  ) async {
    try {
      AppLogger.info(
          'Transfert du prospect #$prospectId de l\'utilisateur $fromUserId vers $toUserId');

      await _transactionService.executeTransaction(
        (connection) async {
          // Étape 1: Vérifier que le prospect existe et que fromUserId est le propriétaire
          final prospectResult = await connection.query(
            'SELECT id_prospect, assignation FROM Prospect WHERE id_prospect = ? FOR UPDATE',
            [prospectId],
          );

          if (prospectResult.isEmpty) {
            throw DatabaseException(
              message: 'Prospect #$prospectId non trouvé',
              code: 'NOT_FOUND',
            );
          }

          final currentOwner = prospectResult.first['assignation'] as int;
          if (currentOwner != fromUserId) {
            throw DatabaseException(
              message:
                  'Prospect #$prospectId n\'appartient pas à l\'utilisateur $fromUserId',
              code: 'UNAUTHORIZED',
            );
          }

          // Étape 2: Transférer le prospect
          await connection.query(
            'UPDATE Prospect SET assignation = ?, date_update = NOW() WHERE id_prospect = ?',
            [toUserId, prospectId],
          );

          AppLogger.debug('Prospect assigné au nouvel utilisateur');

          // Étape 3: Enregistrer le transfert dans l'historique
          await connection.query(
            '''INSERT INTO TransferHistory 
               (prospect_id, from_user_id, to_user_id, transferred_at) 
               VALUES (?, ?, ?, NOW())''',
            [prospectId, fromUserId, toUserId],
          );

          AppLogger.debug('Transfert enregistré dans l\'historique');
        },
      );

      AppLogger.success(
          'Prospect #$prospectId transféré avec succès de $fromUserId à $toUserId');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors du transfert du prospect #$prospectId', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un prospect avec validations atomiques
  ///
  /// Assure que:
  /// 1. Pas de doublons d'email
  /// 2. Prospect créé et associé à l'utilisateur
  /// 3. Enregistrement dans l'audit log
  Future<int> createProspectAtomic(
    int userId,
    String nom,
    String prenom,
    String email,
    String telephone,
    String adresse,
    String type,
  ) async {
    try {
      AppLogger.info('Création du prospect: $prenom $nom ($email)');

      int prospectId = 0;

      await _transactionService.executeTransaction(
        (connection) async {
          // Étape 1: Vérifier qu'aucun prospect avec cet email n'existe
          final existingResult = await connection.query(
            'SELECT COUNT(*) as count FROM Prospect WHERE email = ? AND deleted_at IS NULL',
            [email],
          );

          final count = existingResult.first['count'] as int;
          if (count > 0) {
            throw DatabaseException(
              message: 'Un prospect avec l\'email "$email" existe déjà',
              code: 'DUPLICATE_EMAIL',
            );
          }

          // Étape 2: Créer le prospect
          final insertResult = await connection.query(
            '''INSERT INTO Prospect 
               (nomp, prenomp, email, telephone, adresse, type, assignation, status, creation, date_update) 
               VALUES (?, ?, ?, ?, ?, ?, ?, 'nouveau', NOW(), NOW())''',
            [nom, prenom, email, telephone, adresse, type, userId],
          );

          prospectId = insertResult.insertId as int;
          AppLogger.debug('Prospect créé avec ID: $prospectId');

          // Étape 3: Enregistrer dans l'audit
          await connection.query(
            '''INSERT INTO AuditLog 
               (user_id, action, table_name, record_id, new_value, created_at) 
               VALUES (?, 'CREATE', 'Prospect', ?, ?, NOW())''',
            [
              userId,
              prospectId,
              'Prospect: $nom $prenom, Email: $email',
            ],
          );

          AppLogger.debug('Entrée d\'audit créée');
        },
      );

      AppLogger.success('Prospect créé avec succès (ID: $prospectId)');
      return prospectId;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du prospect: $nom $prenom', e,
          stackTrace);
      rethrow;
    }
  }
}
