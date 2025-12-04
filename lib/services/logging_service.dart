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

  // === LOGGING SPÉCIALISÉ POUR LES EXPORTS ===

  /// Log le début d'une opération d'export
  Future<void> logExportStart(
    String fileName,
    String? directoryPath,
    int prospectCount,
  ) async {
    final message =
        '📤 EXPORT_START | Fichier: $fileName | Répertoire: ${directoryPath ?? "défaut"} | Prospects: $prospectCount';
    await log(message, level: 'INFO');
  }

  /// Log la sélection du répertoire d'export
  Future<void> logDirectorySelection(
    String? selectedPath,
    bool isSuccess,
    String? errorMessage,
  ) async {
    if (isSuccess) {
      final message = '✅ DIR_SELECT_SUCCESS | Chemin: $selectedPath';
      await log(message, level: 'INFO');
    } else {
      final message =
          '❌ DIR_SELECT_FAILED | Erreur: ${errorMessage ?? "Aucun répertoire sélectionné"}';
      await log(message, level: 'WARN');
    }
  }

  /// Log la création du répertoire
  Future<void> logDirectoryCreation(
    String path,
    bool isSuccess,
    String? errorMessage,
  ) async {
    if (isSuccess) {
      final message = '✅ DIR_CREATE_SUCCESS | Chemin: $path';
      await log(message, level: 'INFO');
    } else {
      final message =
          '❌ DIR_CREATE_FAILED | Chemin: $path | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      await log(message, level: 'ERROR');
    }
  }

  /// Log la génération du fichier Excel
  Future<void> logExcelGeneration(
    int rowCount,
    int sheetCount,
    bool isSuccess,
    String? errorMessage,
  ) async {
    if (isSuccess) {
      final message =
          '✅ EXCEL_GEN_SUCCESS | Lignes: $rowCount | Feuilles: $sheetCount';
      await log(message, level: 'INFO');
    } else {
      final message =
          '❌ EXCEL_GEN_FAILED | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      await log(message, level: 'ERROR');
    }
  }

  /// Log la sauvegarde du fichier
  Future<void> logFileSave(
    String filePath,
    int fileSizeBytes,
    bool isSuccess,
    String? errorMessage,
  ) async {
    if (isSuccess) {
      final fileSizeKB = fileSizeBytes / 1024;
      final message =
          '✅ FILE_SAVE_SUCCESS | Chemin: $filePath | Taille: ${fileSizeKB.toStringAsFixed(2)}KB';
      await log(message, level: 'INFO');
    } else {
      final message =
          '❌ FILE_SAVE_FAILED | Chemin: $filePath | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      await log(message, level: 'ERROR');
    }
  }

  /// Log l'erreur globale d'export
  Future<void> logExportError(
    String stage,
    String errorMessage,
    StackTrace? stackTrace,
  ) async {
    final message = '🔴 EXPORT_ERROR | Stage: $stage | Message: $errorMessage';
    await log(message, level: 'ERROR');
    if (stackTrace != null) {
      await log('Stack trace:\n$stackTrace', level: 'ERROR');
    }
  }

  /// Log la fin réussie d'un export
  Future<void> logExportSuccess(
    String filePath,
    int prospectCount,
    Duration duration,
  ) async {
    final message =
        '🎉 EXPORT_SUCCESS | Fichier: $filePath | Prospects: $prospectCount | Durée: ${duration.inMilliseconds}ms';
    await log(message, level: 'INFO');
  }

  /// Obtient un résumé des logs d'export
  Future<String> getExportLogsSummary() async {
    final files = await getLogFiles();
    final summary = StringBuffer();

    summary.writeln('📊 RÉSUMÉ DES EXPORTS');
    summary.writeln('=' * 50);

    for (final logFile in files) {
      final content = await logFile.readAsString();
      final exportLines = content.split('\n').where((line) {
        return line.contains('EXPORT_') ||
            line.contains('DIR_SELECT_') ||
            line.contains('DIR_CREATE_') ||
            line.contains('FILE_SAVE_');
      }).toList();

      if (exportLines.isNotEmpty) {
        summary.writeln('\n📅 ${logFile.path.split('/').last}');
        summary.writeln('-' * 50);
        for (final line in exportLines) {
          summary.writeln(line);
        }
      }
    }

    return summary.toString();
  }

  /// Filtre les logs pour trouver les erreurs d'export
  Future<List<String>> findExportErrors() async {
    final files = await getLogFiles();
    final errors = <String>[];

    for (final logFile in files) {
      final content = await logFile.readAsString();
      final errorLines = content.split('\n').where((line) {
        return line.contains('EXPORT_ERROR') ||
            line.contains('DIR_CREATE_FAILED') ||
            line.contains('FILE_SAVE_FAILED') ||
            line.contains('❌');
      }).toList();

      errors.addAll(errorLines);
    }

    return errors;
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
