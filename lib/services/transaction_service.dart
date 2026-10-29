import 'package:mysql1/mysql1.dart' as mysql;
import 'mysql_service.dart';
import 'connection_pool_service.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

/// Service de gestion des transactions MySQL
/// Fournit des opérations atomiques avec retry logic et gestion des deadlocks
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();

  final MySQLService _mysqlService = MySQLService();
  final ConnectionPoolService _pool = ConnectionPoolService();

  factory TransactionService() {
    return _instance;
  }

  TransactionService._internal();

  /// Exécute une opération dans une transaction avec rollback automatique
  ///
  /// Exemple:
  /// ```dart
  /// await transactionService.executeTransaction((conn) async {
  ///   await conn.query('UPDATE prospects SET status = ? WHERE id = ?', ['intéressé', 5]);
  ///   await conn.query('INSERT INTO status_history VALUES (?, ?, NOW())', [5, 'intéressé']);
  /// });
  /// ```
  Future<T> executeTransaction<T>(
    Future<T> Function(mysql.MySqlConnection) callback, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      mysql.MySqlConnection? connection;
      var connectionBroken = false;
      try {
        // Obtenir une connexion du pool
        connection = await _getConnection();

        // Démarrer la transaction
        await connection.query('START TRANSACTION');
        AppLogger.debug('Transaction démarrée');

        // Exécuter le callback
        final result = await callback(connection);

        // Commit si succès
        await connection.query('COMMIT');
        AppLogger.success('Transaction commitée avec succès');

        return result;
      } catch (e, stackTrace) {
        connectionBroken = e is mysql.MySqlException &&
            const {2002, 2003, 2006, 2013}.contains(e.errorNumber);
        final isRetryableLockError = e is DeadlockException ||
            (e is mysql.MySqlException &&
                (e.errorNumber == 1213 || e.errorNumber == 1205));
        if (isRetryableLockError) {
          retryCount++;
          if (connection != null) {
            try {
              await connection.query('ROLLBACK');
              AppLogger.warning(
                  'Rollback après conflit de verrou (tentative $retryCount)');
            } catch (rollbackError) {
              AppLogger.error('Erreur lors du rollback', rollbackError);
            }
          }
          if (retryCount >= maxRetries) {
            throw DatabaseException(
              message:
                  'Conflit de verrou détecté après $maxRetries tentatives.',
              originalException: e is Exception ? e : null,
              stackTrace: stackTrace,
            );
          }
          await Future.delayed(retryDelay * retryCount);
          continue;
        }

        // Rollback en cas d'erreur
        if (connection != null) {
          try {
            await connection.query('ROLLBACK');
            AppLogger.warning('Rollback après erreur: $e');
          } catch (rollbackError) {
            AppLogger.error('Erreur lors du rollback', rollbackError);
          }
        }

        AppLogger.error('Erreur lors de la transaction', e, stackTrace);

        // Ne pas retry sur les erreurs autres que deadlock
        if (e is DatabaseException || e is ValidationException) {
          rethrow;
        }

        throw DatabaseException(
          message: 'Erreur lors de la transaction: $e',
          originalException: e is Exception ? e : null,
          stackTrace: stackTrace,
        );
      } finally {
        // Retourner la connexion au pool
        if (connection != null) {
          if (connectionBroken && _pool.isInitialized) {
            await _pool.discardConnection(connection);
          } else {
            await _releaseConnection(connection);
          }
        }
      }
    }

    throw StateError('Cette ligne ne devrait pas être atteinte');
  }

  /// Exécute une opération avec verrouillage pessimiste (SELECT FOR UPDATE)
  /// Utilisé pour les opérations critiques où l'isolation est essentielle
  ///
  /// Exemple:
  /// ```dart
  /// final prospect = await transactionService.executeWithLock(
  ///   prospectId: 5,
  ///   tableName: 'prospect',
  ///   callback: (conn, prospect) async {
  ///     // prospect est verrouillé, personne d'autre ne peut le modifier
  ///     await conn.query('UPDATE prospect SET status = ? WHERE id = ?', ['contact_fait', 5]);
  ///   },
  /// );
  /// ```
  Future<T> executeWithLock<T>({
    required int recordId,
    required String tableName,
    String idColumn = 'id',
    required Future<T> Function(mysql.MySqlConnection, Map<String, dynamic>)
        callback,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    mysql.MySqlConnection? connection;
    var transactionStarted = false;
    var connectionBroken = false;

    try {
      const allowedTables = {
        'Account',
        'AdminRecovery',
        'Prospect',
        'Interaction',
        'StatusHistory',
        'TransferHistory',
        'taches',
        'documents',
      };
      const allowedColumns = {
        'id',
        'id_compte',
        'id_prospect',
        'id_interaction',
        'id_tache',
        'id_document',
      };
      if (!allowedTables.contains(tableName) ||
          !allowedColumns.contains(idColumn)) {
        throw ValidationException(
          message: 'Table ou colonne non autorisée pour un verrouillage.',
          code: 'INVALID_LOCK_TARGET',
        );
      }
      connection = await _getConnection();
      await connection.query('START TRANSACTION');
      transactionStarted = true;
      await connection.query(
        'SET SESSION innodb_lock_wait_timeout = ?',
        [timeout.inSeconds.clamp(1, 300)],
      );

      // Verrouiller le record avec SELECT FOR UPDATE
      final results = await connection.query(
        'SELECT * FROM $tableName WHERE $idColumn = ? FOR UPDATE',
        [recordId],
      );

      if (results.isEmpty) {
        throw DatabaseException(
          message: 'Record #$recordId non trouvé dans $tableName',
          code: 'NOT_FOUND',
        );
      }

      final record = results.first.fields;

      // Exécuter le callback avec le record verrouillé
      final result = await callback(connection, record);
      await connection.query('COMMIT');
      transactionStarted = false;

      return result;
    } catch (e, stackTrace) {
      connectionBroken = e is mysql.MySqlException &&
          const {2002, 2003, 2006, 2013}.contains(e.errorNumber);
      AppLogger.error('Erreur lors de executeWithLock', e, stackTrace);
      rethrow;
    } finally {
      if (transactionStarted && connection != null) {
        try {
          await connection.query('ROLLBACK');
        } catch (rollbackError) {
          AppLogger.error('Erreur lors du rollback du verrou', rollbackError);
        }
      }
      if (connection != null) {
        if (connectionBroken && _pool.isInitialized) {
          await _pool.discardConnection(connection);
        } else {
          await _releaseConnection(connection);
        }
      }
    }
  }

  /// Obtient une connexion (du pool à l'avenir, actuellement singleton)
  Future<mysql.MySqlConnection> _getConnection() async {
    if (_pool.isInitialized) {
      return _pool.getConnection();
    }
    return _mysqlService.getConnection();
  }

  /// Retourne la connexion au pool
  Future<void> _releaseConnection(mysql.MySqlConnection connection) async {
    if (_pool.isInitialized) {
      _pool.releaseConnection(connection);
    }
  }
}

/// Exception levée lors d'un deadlock MySQL
class DeadlockException implements Exception {
  final String message;
  final int? code; // Code d'erreur MySQL (1213)
  final String? sqlState;

  DeadlockException({
    required this.message,
    this.code,
    this.sqlState,
  });

  @override
  String toString() => message;

  /// Factory pour créer depuis une exception MySQL
  factory DeadlockException.fromMySQLException(mysql.MySqlException e) {
    return DeadlockException(
      message: 'Deadlock détecté: ${e.message}',
      code: e.errorNumber,
      sqlState: e.sqlState,
    );
  }
}

/// Exception levée lors d'une violation de constraint
class ConstraintViolationException implements Exception {
  final String message;
  final String? field;
  final dynamic value;

  ConstraintViolationException({
    required this.message,
    this.field,
    this.value,
  });

  @override
  String toString() => message;
}
