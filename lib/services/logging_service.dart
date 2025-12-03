import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  late Directory _logsDirectory;
  late File _currentLogFile;
  bool _initialized = false;

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal();

  /// Initialise le service de logging et crée le dossier Prospectius
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Obtenir le répertoire approprié selon la plateforme
      final baseDir = Platform.isWindows
          ? Directory('${Platform.environment['APPDATA']}\\Prospectius')
          : Directory(
              '${(await getApplicationDocumentsDirectory()).path}/Prospectius');

      _logsDirectory = Directory('${baseDir.path}/logs');

      // Créer les dossiers s'ils n'existent pas
      if (!baseDir.existsSync()) {
        await baseDir.create(recursive: true);
      }
      if (!_logsDirectory.existsSync()) {
        await _logsDirectory.create(recursive: true);
      }

      // Créer le fichier log du jour
      _createDailyLogFile();

      _initialized = true;

      // Log initial
      log('=== Démarrage de Prospectius ===');
      log('Répertoire logs: ${_logsDirectory.path}');
      log('Plateforme: ${Platform.operatingSystem}');
    } catch (e) {
      print('Erreur lors de l\'initialisation du logging: $e');
    }
  }

  /// Crée un nouveau fichier log pour le jour actuel
  void _createDailyLogFile() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final today = dateFormat.format(DateTime.now());
    final logFileName = 'prospectius_$today.log';
    _currentLogFile = File('${_logsDirectory.path}/$logFileName');
  }

  /// Enregistre un message de log
  Future<void> log(String message, {String level = 'INFO'}) async {
    if (!_initialized) return;

    try {
      final timeFormat = DateFormat('HH:mm:ss.SSS');
      final timestamp = timeFormat.format(DateTime.now());
      final logEntry = '[$timestamp] [$level] $message\n';

      // Vérifier si on a changé de jour
      final dateFormat = DateFormat('yyyy-MM-dd');
      final fileName = _currentLogFile.path.split('/').last;
      final fileDate =
          fileName.replaceAll('prospectius_', '').replaceAll('.log', '');
      final today = dateFormat.format(DateTime.now());

      if (fileDate != today) {
        _createDailyLogFile();
      }

      // Écrire dans le fichier
      await _currentLogFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Erreur lors de l\'écriture du log: $e');
    }
  }

  /// Enregistre une erreur
  Future<void> logError(String message, [StackTrace? stackTrace]) async {
    await log(message, level: 'ERROR');
    if (stackTrace != null) {
      await log(stackTrace.toString(), level: 'ERROR');
    }
  }

  /// Enregistre un avertissement
  Future<void> logWarning(String message) async {
    await log(message, level: 'WARN');
  }

  /// Enregistre une information
  Future<void> logInfo(String message) async {
    await log(message, level: 'INFO');
  }

  /// Enregistre une action de débogage
  Future<void> logDebug(String message) async {
    await log(message, level: 'DEBUG');
  }

  /// Retourne le chemin du dossier logs
  String get logsPath => _logsDirectory.path;

  /// Retourne le dossier Prospectius
  String get prospectiumPath => _logsDirectory.parent.path;

  /// Obtient la liste des fichiers logs
  Future<List<File>> getLogFiles() async {
    if (!_initialized) return [];

    try {
      final files = _logsDirectory.listSync();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Supprime les logs plus anciens que N jours
  Future<void> cleanOldLogs({int daysToKeep = 30}) async {
    if (!_initialized) return;

    try {
      final files = await getLogFiles();
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: daysToKeep));

      for (final file in files) {
        final lastModified = file.lastModifiedSync();
        if (lastModified.isBefore(cutoffDate)) {
          await file.delete();
          await log('Suppression du fichier log ancien: ${file.path}');
        }
      }
    } catch (e) {
      await logError('Erreur lors du nettoyage des logs: $e');
    }
  }

  /// Exporte les logs dans un fichier texte
  Future<String?> exportLogs() async {
    if (!_initialized) return null;

    try {
      final files = await getLogFiles();
      final buffer = StringBuffer();

      buffer.writeln('=== Export des Logs Prospectius ===');
      buffer.writeln('Date d\'export: ${DateTime.now()}');
      buffer.writeln('');

      for (final file in files.toList().reversed) {
        buffer.writeln('--- ${file.path.split('/').last} ---');
        buffer.write(await file.readAsString());
        buffer.writeln('\n');
      }

      final exportFile = File(
          '${_logsDirectory.path}/export_${DateTime.now().millisecondsSinceEpoch}.txt');
      await exportFile.writeAsString(buffer.toString());
      return exportFile.path;
    } catch (e) {
      await logError('Erreur lors de l\'export des logs: $e');
      return null;
    }
  }
}
