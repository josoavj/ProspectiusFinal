import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

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
      user: 'root',
      password: 'root',
      database: 'Prospectius',
    );
  }

  factory MySQLConfig.fromJson(Map<String, dynamic> json) {
    return MySQLConfig(
      host: json['host'] ?? 'localhost',
      port: json['port'] ?? 3306,
      user: json['user'] ?? 'root',
      password: json['password'] ?? 'root',
      database: json['database'] ?? 'Prospectius',
    );
  }

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'user': user,
        'password': password,
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

  dynamic _connection;
  MySQLConfig _config = MySQLConfig.fromDefaults();
  bool _isConnected = false;

  factory MySQLService() {
    return _instance;
  }

  MySQLService._internal();

  bool get isConnected => _isConnected;
  MySQLConfig get config => _config;

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('mysql_config');
      if (configJson != null) {
        try {
          final configMap = jsonDecode(configJson) as Map<String, dynamic>;
          _config = MySQLConfig.fromJson(configMap);
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
      _config = config;
      AppLogger.success('Configuration MySQL sauvegardée');
    } catch (e) {
      AppLogger.error('Erreur lors de la sauvegarde de la config', e);
      rethrow;
    }
  }

  Future<bool> connect(MySQLConfig config) async {
    try {
      AppLogger.info('Connexion à MySQL: ${config.host}:${config.port}');
      _config = config;
      // Create connection using the mysql1 package
      _connection = await mysql.MySqlConnection.connect(
        config.toConnectionSettings(),
      );
      _isConnected = true;
      await saveConfig(config);
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
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
        _isConnected = false;
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
      AppLogger.error('Tentative de requête sans connexion active');
      throw ConnectionException(
        message: 'MySQL non connecté',
        code: 'NOT_CONNECTED',
      );
    }
    try {
      return await _connection!.query(sql, values);
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'exécution de la requête', e, stackTrace);
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
