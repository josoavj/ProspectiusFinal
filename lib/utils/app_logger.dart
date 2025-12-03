import 'package:logger/logger.dart';
import '../services/logging_service.dart';

/// Service de logging centralisé pour l'application
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final LoggingService _fileLogger = LoggingService();

  /// Log d'information
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _fileLogger.logInfo(message);
  }

  /// Log de debug
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _fileLogger.logDebug(message);
  }

  /// Log d'erreur
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _fileLogger.logError(message, stackTrace);
  }

  /// Log d'avertissement
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _fileLogger.logWarning(message);
  }

  /// Log de succès
  static void success(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
    _fileLogger.logInfo('✓ $message');
  }

  /// Log avec un titre de section
  static void section(String title) {
    final sectionStr = '========== $title ==========';
    _logger.i(sectionStr);
    _fileLogger.logInfo(sectionStr);
  }

  /// Log les paramètres de requête
  static void logRequest(String method, String sql, [List<dynamic>? params]) {
    _logger.d('[$method] $sql', error: params);
    _fileLogger.logDebug('[$method] $sql');
    if (params != null) {
      _fileLogger.logDebug('Params: $params');
    }
  }

  /// Log les résultats de requête
  static void logResponse(String method, int rows) {
    _logger.i('[$method] ✓ $rows row(s) affected');
    _fileLogger.logInfo('[$method] ✓ $rows row(s) affected');
  }
}
