import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  ConnectionSettings toConnectionSettings() {
    return ConnectionSettings(
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

  MySQLConnection? _connection;
  MySQLConfig _config = MySQLConfig.fromDefaults();
  bool _isConnected = false;

  factory MySQLService() {
    return _instance;
  }

  MySQLService._internal();

  bool get isConnected => _isConnected;
  MySQLConfig get config => _config;

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('mysql_config');
    if (configJson != null) {
      _config = MySQLConfig.fromJson(
        Map<String, dynamic>.from(
          Map.from(Uri.parse('?$configJson').queryParameters),
        ),
      );
    }
  }

  Future<void> saveConfig(MySQLConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mysql_config', config.toJson().toString());
    _config = config;
  }

  Future<bool> connect(MySQLConfig config) async {
    try {
      _config = config;
      _connection = await MySQLConnection.connect(
        config.toConnectionSettings(),
      );
      _isConnected = true;
      await saveConfig(config);
      return true;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      _isConnected = false;
    }
  }

  Future<Results> query(String sql, [List<dynamic> values = const []]) async {
    if (_connection == null || !_isConnected) {
      throw Exception('MySQL non connecté');
    }
    return await _connection!.query(sql, values);
  }

  Future<void> close() async {
    await disconnect();
  }
}
