import 'package:mysql1/mysql1.dart' as mysql;
import 'dart:async';
import 'dart:collection';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';
import 'mysql_service.dart';
import 'error_handling_service.dart';

/// Service de pool de connexions MySQL pour support multi-utilisateurs
/// Gère un pool de connexions réutilisables avec file d'attente
class ConnectionPoolService {
  static final ConnectionPoolService _instance =
      ConnectionPoolService._internal();

  late int _poolSize;
  final Queue<mysql.MySqlConnection> _availableConnections = Queue();
  final List<mysql.MySqlConnection> _allConnections = [];
  final List<Completer<mysql.MySqlConnection>> _waitingRequests = [];

  MySQLConfig? _config;
  bool _isInitialized = false;

  factory ConnectionPoolService({int? poolSize}) {
    if (poolSize != null && poolSize > 0) {
      _instance._poolSize = poolSize;
    }
    return _instance;
  }

  ConnectionPoolService._internal() : _poolSize = 3;

  int get poolSize => _poolSize;
  bool get isInitialized => _isInitialized;
  int get availableConnections => _availableConnections.length;
  int get totalConnections => _allConnections.length;

  /// Initialise le pool avec les connexions
  Future<void> initialize(MySQLConfig config) async {
    if (_isInitialized) {
      AppLogger.warning('Pool de connexions déjà initialisé');
      return;
    }

    _config = config;

    try {
      AppLogger.info(
          'Initialisation du pool de connexions (taille: $poolSize)...');

      for (int i = 0; i < poolSize; i++) {
        try {
          final connection = await mysql.MySqlConnection.connect(
            config.toConnectionSettings(),
          );
          _availableConnections.add(connection);
          _allConnections.add(connection);
          AppLogger.debug('Connexion $i initialisée');
        } catch (e, stackTrace) {
          AppLogger.error('Erreur lors de l\'initialisation de la connexion $i',
              e, stackTrace);
          // Continuer avec les autres connexions
        }
      }

      if (_allConnections.isEmpty) {
        throw ConnectionException(
          message: 'Impossible d\'initialiser le pool de connexions',
          code: 'POOL_INIT_FAILED',
        );
      }

      _isInitialized = true;
      AppLogger.success(
          'Pool de connexions initialisé avec ${_allConnections.length}/$poolSize connexions');
    } catch (e, stackTrace) {
      _isInitialized = false;
      AppLogger.error(
          'Erreur lors de l\'initialisation du pool', e, stackTrace);
      rethrow;
    }
  }

  /// Obtient une connexion du pool
  Future<mysql.MySqlConnection> getConnection(
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (!_isInitialized) {
      throw ConnectionException(
        message: 'Pool de connexions non initialisé',
        code: 'POOL_NOT_INIT',
      );
    }

    // Si une connexion est disponible, la retourner immédiatement
    if (_availableConnections.isNotEmpty) {
      final connection = _availableConnections.removeFirst();
      AppLogger.debug(
          'Connexion obtenue du pool (${_availableConnections.length} restantes)');
      return connection;
    }

    // Sinon, attendre qu'une connexion se libère
    AppLogger.warning(
        'Aucune connexion disponible. File d\'attente: ${_waitingRequests.length}');

    final completer = Completer<mysql.MySqlConnection>();
    _waitingRequests.add(completer);

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _waitingRequests.remove(completer);
        throw TimeoutException(
          message: 'Timeout en attente d\'une connexion disponible',
          operationName: 'Obtenir une connexion du pool',
          timeout: timeout,
        );
      },
    );
  }

  /// Libère une connexion dans le pool
  void releaseConnection(mysql.MySqlConnection connection) {
    if (!_allConnections.contains(connection)) {
      AppLogger.warning('Tentative de libération d\'une connexion inconnue');
      return;
    }

    // S'il y a des requêtes en attente, donner la connexion au premier
    if (_waitingRequests.isNotEmpty) {
      final waitingRequest = _waitingRequests.removeAt(0);
      if (!waitingRequest.isCompleted) {
        waitingRequest.complete(connection);
        AppLogger.debug(
            'Connexion attribuée à une requête en attente (${_waitingRequests.length} restantes)');
      }
      return;
    }

    // Sinon, ajouter la connexion au pool
    _availableConnections.add(connection);
    AppLogger.debug(
        'Connexion libérée (${_availableConnections.length} disponibles)');
  }

  Future<void> discardConnection(mysql.MySqlConnection connection) async {
    _availableConnections.remove(connection);
    _allConnections.remove(connection);
    try {
      await connection.close();
    } catch (e) {
      AppLogger.warning(
          'Erreur lors de la fermeture d’une connexion défectueuse: $e');
    }
    if (_config == null || !_isInitialized) {
      if (_allConnections.isEmpty) _isInitialized = false;
      return;
    }

    try {
      final replacement = await mysql.MySqlConnection.connect(
        _config!.toConnectionSettings(),
      );
      _allConnections.add(replacement);
      if (_waitingRequests.isNotEmpty) {
        final waitingRequest = _waitingRequests.removeAt(0);
        waitingRequest.complete(replacement);
      } else {
        _availableConnections.add(replacement);
      }
    } catch (e) {
      AppLogger.error('Impossible de remplacer une connexion défectueuse', e);
      if (_allConnections.isEmpty) _isInitialized = false;
    }
  }

  /// Exécute une opération avec une connexion du pool
  Future<T> execute<T>(
    Future<T> Function(mysql.MySqlConnection connection) operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final connection = await getConnection(timeout: timeout);

    try {
      return await operation(connection);
    } catch (e) {
      AppLogger.error('Erreur lors de l\'opération sur le pool', e);
      if (e is mysql.MySqlException) {
        await discardConnection(connection);
      }
      rethrow;
    } finally {
      if (_allConnections.contains(connection)) {
        releaseConnection(connection);
      }
    }
  }

  /// Vérifie la santé du pool
  Future<Map<String, dynamic>> getPoolHealth() async {
    final results = <String, dynamic>{
      'isInitialized': _isInitialized,
      'totalConnections': _allConnections.length,
      'availableConnections': _availableConnections.length,
      'waitingRequests': _waitingRequests.length,
      'poolSize': poolSize,
      'utilizationRate': _allConnections.isEmpty
          ? '0.00'
          : ((_allConnections.length - _availableConnections.length) /
                  _allConnections.length *
                  100)
              .toStringAsFixed(2),
    };

    AppLogger.debug('Pool health: $results');
    return results;
  }

  /// Ferme tous les liens du pool
  Future<void> closeAll() async {
    try {
      AppLogger.info('Fermeture du pool de connexions...');

      for (final connection in _allConnections) {
        try {
          await connection.close();
        } catch (e) {
          AppLogger.warning('Erreur lors de la fermeture d\'une connexion: $e');
        }
      }

      _availableConnections.clear();
      _allConnections.clear();
      for (final request in _waitingRequests) {
        if (!request.isCompleted) {
          request.completeError(
            ConnectionException(
              message: 'Le pool de connexions a été fermé.',
              code: 'POOL_CLOSED',
            ),
          );
        }
      }
      _waitingRequests.clear();
      _isInitialized = false;

      AppLogger.success('Pool de connexions fermé');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la fermeture du pool', e, stackTrace);
    }
  }

  /// Réinitialise le pool
  Future<void> reset() async {
    await closeAll();
    if (_config != null) {
      await initialize(_config!);
    }
  }
}

/// Wrapper pour utiliser le pool de manière simple
class PooledDatabaseOperation {
  final ConnectionPoolService _pool = ConnectionPoolService();

  /// Exécute une requête SQL dans le pool
  Future<mysql.Results> query(String sql,
      [List<dynamic> values = const []]) async {
    return _pool.execute((connection) async {
      return await connection.query(sql, values);
    });
  }

  /// Exécute une mise à jour SQL dans le pool
  Future<mysql.Results> update(String sql,
      [List<dynamic> values = const []]) async {
    return _pool.execute((connection) async {
      return await connection.query(sql, values);
    });
  }

  /// Obtient une connexion directe du pool (usage avancé)
  Future<mysql.MySqlConnection> getConnection() async {
    return _pool.getConnection();
  }

  /// Libère une connexion dans le pool
  void releaseConnection(mysql.MySqlConnection connection) {
    _pool.releaseConnection(connection);
  }
}
