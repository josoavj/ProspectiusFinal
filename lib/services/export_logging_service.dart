import '../utils/app_logger.dart';
import 'logging_service.dart';

/// Service spécialisé pour le logging des opérations d'export
/// Fournit des traces détaillées pour le debugging et l'audit
class ExportLoggingService {
  static final ExportLoggingService _instance =
      ExportLoggingService._internal();
  final LoggingService _loggingService = LoggingService();

  factory ExportLoggingService() {
    return _instance;
  }

  ExportLoggingService._internal();

  /// Log le début d'une opération d'export
  void logExportStart(
    String fileName,
    String? directoryPath,
    int prospectCount,
  ) {
    final message =
        'EXPORT_START | Fichier: $fileName | Répertoire: ${directoryPath ?? "défaut"} | Prospects: $prospectCount';
    AppLogger.info(message);
    _loggingService.log('📤 $message');
  }

  /// Log la sélection du répertoire d'export
  void logDirectorySelection(
    String? selectedPath,
    bool isSuccess,
    String? errorMessage,
  ) {
    if (isSuccess) {
      final message = 'DIR_SELECT_SUCCESS | Chemin: $selectedPath';
      AppLogger.info(message);
      _loggingService.log('✅ $message');
    } else {
      final message =
          'DIR_SELECT_FAILED | Erreur: ${errorMessage ?? "Aucun répertoire sélectionné"}';
      AppLogger.warning(message);
      _loggingService.log('❌ $message');
    }
  }

  /// Log la création du répertoire
  void logDirectoryCreation(
    String path,
    bool isSuccess,
    String? errorMessage,
  ) {
    if (isSuccess) {
      final message = 'DIR_CREATE_SUCCESS | Chemin: $path';
      AppLogger.info(message);
      _loggingService.log('✅ $message');
    } else {
      final message =
          'DIR_CREATE_FAILED | Chemin: $path | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      AppLogger.error(message);
      _loggingService.log('❌ $message');
    }
  }

  /// Log la génération du fichier Excel
  void logExcelGeneration(
    int rowCount,
    int sheetCount,
    bool isSuccess,
    String? errorMessage,
  ) {
    if (isSuccess) {
      final message =
          'EXCEL_GEN_SUCCESS | Lignes: $rowCount | Feuilles: $sheetCount';
      AppLogger.info(message);
      _loggingService.log('✅ $message');
    } else {
      final message =
          'EXCEL_GEN_FAILED | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      AppLogger.error(message);
      _loggingService.log('❌ $message');
    }
  }

  /// Log la sauvegarde du fichier
  void logFileSave(
    String filePath,
    int fileSizeBytes,
    bool isSuccess,
    String? errorMessage,
  ) {
    if (isSuccess) {
      final fileSizeKB = fileSizeBytes / 1024;
      final message =
          'FILE_SAVE_SUCCESS | Chemin: $filePath | Taille: ${fileSizeKB.toStringAsFixed(2)}KB';
      AppLogger.success(message);
      _loggingService.log('✅ $message');
    } else {
      final message =
          'FILE_SAVE_FAILED | Chemin: $filePath | Erreur: ${errorMessage ?? "Erreur inconnue"}';
      AppLogger.error(message);
      _loggingService.log('❌ $message');
    }
  }

  /// Log l'erreur globale d'export
  void logExportError(
    String stage,
    String errorMessage,
    StackTrace? stackTrace,
  ) {
    final message = 'EXPORT_ERROR | Stage: $stage | Message: $errorMessage';
    AppLogger.error(message, null, stackTrace);
    _loggingService.log('🔴 $message');
    if (stackTrace != null) {
      _loggingService.log('Stack trace:\n$stackTrace');
    }
  }

  /// Log la fin réussie d'un export
  void logExportSuccess(
    String filePath,
    int prospectCount,
    Duration duration,
  ) {
    final message =
        'EXPORT_SUCCESS | Fichier: $filePath | Prospects: $prospectCount | Durée: ${duration.inMilliseconds}ms';
    AppLogger.success(message);
    _loggingService.log('🎉 $message');
  }

  /// Obtient un résumé des logs d'export
  Future<String> getExportLogsSummary() async {
    final logs = await _loggingService.getLogFiles();
    final summary = StringBuffer();

    summary.writeln('📊 RÉSUMÉ DES EXPORTS');
    summary.writeln('=' * 50);

    for (final logFile in logs) {
      final content = await logFile.readAsString();
      final exportLines = content.split('\n').where((line) {
        return line.contains('EXPORT_') ||
            line.contains('DIR_SELECT_') ||
            line.contains('DIR_CREATE_') ||
            line.contains('FILE_SAVE_');
      }).toList();

      if (exportLines.isNotEmpty) {
        summary.writeln('\n📅 ${logFile.path}');
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
    final logs = await _loggingService.getLogFiles();
    final errors = <String>[];

    for (final logFile in logs) {
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
}
