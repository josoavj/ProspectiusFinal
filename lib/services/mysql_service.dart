import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';
import 'connection_pool_service.dart';
import 'migration_service.dart';
import 'schema_initialization_service.dart';
import 'secure_storage_service.dart';

class MySQLConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final String database;

  MySQLConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
  });

  factory MySQLConfig.fromDefaults() {
    return MySQLConfig(
      host: 'localhost',
      port: 3306,
      user: '',
      password: '',
      database: 'Prospectius',
    );
  }

  factory MySQLConfig.fromJson(Map<String, dynamic> json) {
    return MySQLConfig(
      host: json['host'] ?? 'localhost',
      port: json['port'] ?? 3306,
      user: json['user'] ?? '',
      password: json['password'] ?? '',
      database: json['database'] ?? 'Prospectius',
    );
  }

  Map<String, dynamic> toJson({bool includePassword = false}) => {
        'host': host,
        'port': port,
        'user': user,
        if (includePassword) 'password': password,
        'database': database,
      };

  mysql.ConnectionSettings toConnectionSettings() {
    return mysql.ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: database,
      timeout: const Duration(seconds: 30),
    );
  }
}

class MySQLService {
  static final MySQLService _instance = MySQLService._internal();

  mysql.MySqlConnection? _connection;
  MySQLConfig _config = MySQLConfig.fromDefaults();
  bool _isConnected = false;
  MigrationService? _migrationService;
  final ConnectionPoolService _pool = ConnectionPoolService();
  bool _usePool = false;
  final SecureStorageService _secureStorage = SecureStorageService();

  factory MySQLService() {
    return _instance;
  }

  MySQLService._internal();

  bool get isConnected => _isConnected;
  MySQLConfig get config => _config;
  MigrationService? get migrationService => _migrationService;

  /// Obtient la connexion MySQL (usage interne pour transactions)
  mysql.MySqlConnection getConnection() {
    if (_connection == null || !_isConnected) {
      throw ConnectionException(
        message: 'MySQL non connecté',
        code: 'NOT_CONNECTED',
      );
    }
    return _connection!;
  }

  Future<void> _connectInternal(
    MySQLConfig config, {
    bool runMigrations = true,
    bool initPool = true,
    bool persistConfig = true,
  }) async {
    AppLogger.info('Connexion à MySQL: ${config.host}:${config.port}');
    _config = config;
    _connection = await mysql.MySqlConnection.connect(
      config.toConnectionSettings(),
    );
    _isConnected = true;

    if (runMigrations) {
      final schemaService = SchemaInitializationService(_connection!);
      await schemaService.initializeSchema();

      _migrationService = MigrationService(_connection!);

      if (persistConfig) {
        await saveConfig(config);
      }

      try {
        await _migrationService!.runPendingMigrations();
      } catch (e) {
        AppLogger.warning('Erreur lors de l\'exécution des migrations: $e');
      }
    }

    if (initPool) {
      try {
        await _pool.initialize(config);
        _usePool = _pool.isInitialized;
      } catch (e) {
        _usePool = false;
        AppLogger.warning('Pool de connexions non initialisé: $e');
      }
    }
  }

  Future<void> _reconnect() async {
    await _connectInternal(
      _config,
      runMigrations: false,
      initPool: false,
      persistConfig: false,
    );

    if (_pool.isInitialized) {
      try {
        await _pool.reset();
        _usePool = true;
      } catch (e) {
        _usePool = false;
        AppLogger.warning('Pool non reinitialise: $e');
      }
    }
  }

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('mysql_config');
      if (configJson != null) {
        try {
          final configMap = jsonDecode(configJson) as Map<String, dynamic>;
          final securePassword = await _secureStorage.getDbPassword();
          _config = MySQLConfig.fromJson(configMap);
          if (securePassword != null) {
            _config = MySQLConfig(
              host: _config.host,
              port: _config.port,
              user: _config.user,
              password: securePassword,
              database: _config.database,
            );
          }
          AppLogger.info('Configuration MySQL chargée');
        } catch (e) {
          AppLogger.warning(
              'Erreur lors du parsing de la config: $e, utilisation des paramètres par défaut');
          _config = MySQLConfig.fromDefaults();
        }
      } else {
        _config = MySQLConfig.fromDefaults();
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement de la config', e);
      _config = MySQLConfig.fromDefaults();
    }
  }

  Future<void> saveConfig(MySQLConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(config.toJson());
      await prefs.setString('mysql_config', configJson);
      if (config.password.isNotEmpty) {
        await _secureStorage.saveDbPassword(config.password);
      }
      _config = config;
      AppLogger.success('Configuration MySQL sauvegardée');
    } catch (e) {
      AppLogger.error('Erreur lors de la sauvegarde de la config', e);
      rethrow;
    }
  }

  Future<bool> connect(MySQLConfig config) async {
    try {
      await _connectInternal(config);
      AppLogger.success('Connexion MySQL établie');
      return true;
    } on ConnectionException {
      _isConnected = false;
      AppLogger.error('Erreur de connexion à MySQL');
      rethrow;
    } catch (e, stackTrace) {
      _isConnected = false;
      AppLogger.error('Erreur lors de la connexion MySQL', e, stackTrace);
      throw ConnectionException(
        message: 'Impossible de se connecter à la base de données: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      if (_pool.isInitialized) {
        await _pool.closeAll();
      }
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
        _isConnected = false;
        _usePool = false;
        AppLogger.info('Déconnecté de MySQL');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la déconnexion', e, stackTrace);
      rethrow;
    }
  }

  Future<mysql.Results> query(String sql,
      [List<dynamic> values = const []]) async {
    if (_connection == null || !_isConnected) {
      AppLogger.warning(
          'Tentative de requête sans connexion active, tentative de reconnexion...');
      // Essayer de reconnecter automatiquement
      try {
        await _reconnect();
      } catch (e) {
        AppLogger.error('Impossible de reconnecter à MySQL', e);
        throw ConnectionException(
          message: 'MySQL non connecté',
          code: 'NOT_CONNECTED',
        );
      }
    }
    try {
      if (_usePool && _pool.isInitialized) {
        return await _pool.execute(
          (connection) async {
            final results = await connection.query(sql, values);
            AppLogger.debug('SQL Execute: $sql | Rows: ${results.length}');
            return results;
          },
        );
      }
      final results = await _connection!.query(sql, values);
      AppLogger.debug('SQL Execute: $sql | Rows: ${results.length}');
      return results;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'exécution de la requête', e, stackTrace);
      // Marquer comme déconnecté et rethrow
      _isConnected = false;
      throw DatabaseException(
        message: 'Erreur lors de l\'exécution de la requête: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> close() async {
    await disconnect();
  }
}
