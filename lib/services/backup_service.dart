import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'mysql_service.dart';
import '../utils/app_logger.dart';

class BackupService {
  final MySQLService _mysqlService;

  BackupService(this._mysqlService);

  /// Retourne le chemin par défaut des sauvegardes
  Future<String> getDefaultBackupDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final separator = Platform.isWindows ? '\\' : '/';
    return '${docDir.path}${separator}Prospectius${separator}backups';
  }

  /// Génère un script SQL complet de sauvegarde (Structure + Données)
  Future<String?> createFullBackup({String? directoryPath}) async {
    try {
      final dbName = _mysqlService.config.database;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'backup_${dbName.toLowerCase()}_$timestamp.sql';
      
      String? savePath;
      if (directoryPath != null) {
        savePath = '$directoryPath${Platform.isWindows ? '\\' : '/'}$fileName';
      } else {
        final backupDir = Directory(await getDefaultBackupDirectory());
        if (!backupDir.existsSync()) await backupDir.create(recursive: true);
        savePath = '${backupDir.path}${Platform.isWindows ? '\\' : '/'}$fileName';
      }

      final buffer = StringBuffer();
      buffer.writeln('-- Prospectius Database Backup');
      buffer.writeln('-- Date: ${DateTime.now()}');
      buffer.writeln('-- Database: $dbName');
      buffer.writeln('\nSET FOREIGN_KEY_CHECKS = 0;\n');

      // 1. Lister les tables
      final tablesResult = await _mysqlService.query('SHOW TABLES');
      final tables = tablesResult.map((row) => row.fields.values.first.toString()).toList();

      for (var table in tables) {
        AppLogger.info('Sauvegarde de la table: $table');
        
        // 2. Structure de la table
        final createResult = await _mysqlService.query('SHOW CREATE TABLE $table');
        final createSql = createResult.first.fields['Create Table'];
        
        buffer.writeln('-- Structure for table `$table`');
        buffer.writeln('DROP TABLE IF EXISTS `$table`;');
        buffer.writeln('$createSql;\n');

        // 3. Données de la table
        final dataResult = await _mysqlService.query('SELECT * FROM $table');
        if (dataResult.isNotEmpty) {
          buffer.writeln('-- Data for table `$table`');
          for (var row in dataResult) {
            final columns = row.fields.keys.map((k) => '`$k`').join(', ');
            final values = row.fields.values.map((v) {
              if (v == null) return 'NULL';
              if (v is num || v is bool) return v.toString();
              return "'${v.toString().replaceAll("'", "''")}'";
            }).join(', ');
            
            buffer.writeln('INSERT INTO `$table` ($columns) VALUES ($values);');
          }
          buffer.writeln();
        }
      }

      buffer.writeln('SET FOREIGN_KEY_CHECKS = 1;');

      final file = File(savePath);
      await file.writeAsString(buffer.toString());
      
      AppLogger.success('Sauvegarde réussie: $savePath');
      return savePath;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la sauvegarde', e, stackTrace);
      return null;
    }
  }
}
