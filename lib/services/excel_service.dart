import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prospect.dart';
import '../utils/app_logger.dart';
import '../utils/exception_handler.dart';

class ExcelService {
  /// Exporte les prospects vers un fichier Excel dans le répertoire spécifié
  Future<String> exportProspectsToExcel(
    List<Prospect> prospects, {
    required String fileName,
    String? directoryPath,
  }) async {
    try {
      AppLogger.info('Démarrage de l\'export Excel: ${prospects.length} prospects');

      // Créer un nouveau classeur
      final excel = Excel.createExcel();
      final dataSheet = excel['Sheet1'];

      // En-têtes
      final headers = [
        'Nom',
        'Prénom',
        'Email',
        'Téléphone',
        'Adresse',
        'Type',
        'Statut',
        'Date de création',
        'Dernière modification',
      ];

      // Ajouter les en-têtes avec style
      for (int i = 0; i < headers.length; i++) {
        dataSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(headers[i])
          ..cellStyle = CellStyle(
            bold: true,
          );
      }

      // Ajouter les données des prospects
      for (int row = 0; row < prospects.length; row++) {
        final prospect = prospects[row];
        final cells = [
          prospect.nom,
          prospect.prenom,
          prospect.email,
          prospect.telephone,
          prospect.adresse,
          prospect.type,
          prospect.status,
          prospect.creation.toString().split(' ')[0],
          prospect.dateUpdate.toString().split(' ')[0],
        ];

        for (int col = 0; col < cells.length; col++) {
          final cell = dataSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: row + 1,
          ));
          cell.value = TextCellValue(cells[col]);

          // Ajouter la couleur de background selon le statut (colonne 6 = statut)
          if (col == 6) {
            cell.cellStyle = CellStyle(
              bold: true,
            );
          }
        }
      } // Créer l'onglet de statistiques
      final statsSheet = excel['Statistiques'];

      // Ajouter les statistiques
      _addStatistics(statsSheet, prospects);

      // Déterminer le chemin de destination
      final String savePath;
      if (directoryPath != null && directoryPath.isNotEmpty) {
        // Utiliser le répertoire fourni par l'utilisateur
        var dir = Directory(directoryPath);

        // Créer le répertoire s'il n'existe pas
        // ignore: avoid_slow_async_io
        if (!await dir.exists()) {
          AppLogger.info('Création du répertoire: $directoryPath');
          try {
            await dir.create(recursive: true);
          } on FileSystemException catch (e) {
            AppLogger.error('Erreur lors de la création du répertoire', e);
            throw Exception(
              'Impossible de créer le répertoire: $directoryPath\nErreur: $e',
            );
          }
        }
        // Utiliser le séparateur de chemin approprié au système d'exploitation
        final separator = Platform.isWindows ? '\\' : '/';
        savePath = '$directoryPath$separator$fileName.xlsx';
      } else {
        // Utiliser le répertoire de documents par défaut
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName.xlsx';
      }

      // Sauvegarder le fichier
      final file = File(savePath);
      final bytes = excel.encode();
      if (bytes != null) {
        try {
          await file.writeAsBytes(bytes);
          AppLogger.success('Fichier Excel créé: $savePath');
        } catch (e) {
          // Si l'erreur est due à des permissions, donner un message clair
          AppLogger.error('Erreur lors de l\'écriture du fichier', e);
          throw Exception(
            'Impossible d\'écrire le fichier à cet emplacement: $savePath\n'
            'Vérifiez que vous avez les permissions d\'écriture.\n'
            'Erreur: $e',
          );
        }
      }
      return savePath;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'export Excel', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de l\'export: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  /// Ajoute les statistiques dans la feuille Excel
  void _addStatistics(Sheet sheet, List<Prospect> prospects) {
    int row = 0;

    // Titre
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('STATISTIQUES')
      ..cellStyle = CellStyle(bold: true);
    row += 2;

    // Total prospects
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Total prospects')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = IntCellValue(prospects.length);
    row += 2;

    // Statistiques par statut
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Par statut')
      ..cellStyle = CellStyle(bold: true);
    row += 1;

    final statusMap = <String, int>{};
    for (final prospect in prospects) {
      statusMap[prospect.status] = (statusMap[prospect.status] ?? 0) + 1;
    }

    for (final status in [
      'interesse',
      'negociation',
      'converti',
      'perdu'
    ]) {
      if (statusMap.containsKey(status)) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(_formatStatus(status));
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = IntCellValue(statusMap[status] ?? 0);
        row += 1;
      }
    }

    row += 2;

    // Statistiques par mois
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Par mois')
      ..cellStyle = CellStyle(bold: true);
    row += 1;

    final monthMap = <String, int>{};
    for (final prospect in prospects) {
      final month = _formatMonth(prospect.creation);
      monthMap[month] = (monthMap[month] ?? 0) + 1;
    }

    // Trier par mois
    final sortedMonths = monthMap.keys.toList()..sort();
    for (final month in sortedMonths) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(month);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = IntCellValue(monthMap[month] ?? 0);
      row += 1;
    }

    row += 2;

    // Statistiques par type
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Par type')
      ..cellStyle = CellStyle(bold: true);
    row += 1;

    final typeMap = <String, int>{};
    for (final prospect in prospects) {
      typeMap[prospect.type] = (typeMap[prospect.type] ?? 0) + 1;
    }

    for (final entry in typeMap.entries) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(_formatType(entry.key));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = IntCellValue(entry.value);
      row += 1;
    }

    row += 2;

    // Performances
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('PERFORMANCES')
      ..cellStyle = CellStyle(bold: true);
    row += 2;

    // Taux de conversion
    final convertis = statusMap['converti'] ?? 0;
    final tauxConversion =
        prospects.isEmpty ? 0.0 : (convertis / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Taux de conversion')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('${tauxConversion.toStringAsFixed(2)}%');
    row += 1;

    // Taux de perte
    final perdus = statusMap['perdu'] ?? 0;
    final tauxPerte =
        prospects.isEmpty ? 0.0 : (perdus / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Taux de perte')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('${tauxPerte.toStringAsFixed(2)}%');
    row += 1;

    // Taux d'engagement (interessé + en négociation)
    final engages =
        (statusMap['interesse'] ?? 0) + (statusMap['negociation'] ?? 0);
    final tauxEngagement =
        prospects.isEmpty ? 0.0 : (engages / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Taux d\'engagement')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('${tauxEngagement.toStringAsFixed(2)}%');
    row += 1;

    // Prospects en attente (non convertis et non perdus)
    final enAttente = prospects.length - convertis - perdus;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Prospects en attente')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = IntCellValue(enAttente);
    row += 2;

    // Moyenne de prospects par mois
    final moyenneParMois =
        monthMap.isEmpty ? 0.0 : prospects.length / monthMap.length;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Moyenne de prospects/mois')
      ..cellStyle = CellStyle(bold: true);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(moyenneParMois.toStringAsFixed(2));
    row += 1;

    // Prospect le plus récent
    if (prospects.isNotEmpty) {
      final plusRecent =
          prospects.reduce((a, b) => a.creation.isAfter(b.creation) ? a : b);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue('Prospect le plus récent')
        ..cellStyle = CellStyle(bold: true);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(_formatMonth(plusRecent.creation));
      row += 1;
    }

    // Prospect le plus ancien
    if (prospects.isNotEmpty) {
      final plusAncien =
          prospects.reduce((a, b) => a.creation.isBefore(b.creation) ? a : b);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue('Prospect le plus ancien')
        ..cellStyle = CellStyle(bold: true);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(_formatMonth(plusAncien.creation));
      row += 1;
    }
  }

  /// Formate le statut
  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  /// Formate le type
  String _formatType(String type) {
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }

  /// Formate la date en mois-année
  String _formatMonth(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Ouvre un dialogue pour choisir le répertoire de sauvegarde
  Future<String?> pickExportDirectory() async {
    try {
      AppLogger.info('Ouverture du dialogue de sélection de dossier');

      // Sur Linux, utiliser zenity ou kdialog pour ouvrir un dialogue
      if (Platform.isLinux) {
        try {
          // Essayer d'abord avec zenity
          final result = await Process.run(
            'zenity',
            [
              '--file-selection',
              '--directory',
              '--title=Sélectionner le dossier de destination'
            ],
          );

          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          }
        } catch (e) {
          AppLogger.warning('Zenity non disponible, tentative avec kdialog');
          try {
            // Essayer avec kdialog
            final result = await Process.run(
              'kdialog',
              [
                '--getexistingdirectory',
                Platform.environment['HOME'] ?? '/home'
              ],
            );

            if (result.exitCode == 0) {
              return result.stdout.toString().trim();
            }
          } catch (e2) {
            AppLogger.warning('Dialogues natifs non disponibles');
            return null;
          }
        }
      } else if (Platform.isMacOS) {
        // Sur macOS
        try {
          final result = await Process.run(
            'osascript',
            [
              '-e',
              'tell app "System Events" to choose folder with prompt "Sélectionner le dossier de destination:" as alias',
            ],
          );

          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          }
        } catch (e) {
          AppLogger.warning('Dialogue macOS indisponible');
          return null;
        }
      } else if (Platform.isWindows) {
        // Sur Windows - utiliser PowerShell avec FolderBrowserDialog
        try {
          final result = await Process.run(
            'powershell',
            [
              '-Command',
              r'[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null; $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog; $folderDialog.Description = "Sélectionner le dossier de destination"; if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $folderDialog.SelectedPath }',
            ],
          );

          if (result.exitCode == 0) {
            final selectedPath = result.stdout.toString().trim();
            if (selectedPath.isNotEmpty) {
              AppLogger.info('Répertoire sélectionné: $selectedPath');
              return selectedPath;
            }
          }
        } catch (e) {
          AppLogger.warning('Dialogue Windows PowerShell indisponible: $e');
        }

        // Fallback: essayer avec cmd.exe et vbscript
        try {
          const vbScript = '''
Set shell = CreateObject("Shell.Application")
Set folder = shell.BrowseForFolder(0, "Sélectionner le dossier de destination:", 0, 0)
If Not folder Is Nothing Then
  WScript.Echo folder.Self.Path
End If
''';

          // Créer un fichier temporaire VB
          final tempDir = Directory.systemTemp;
          final separator = Platform.isWindows ? '\\' : '/';
          final vbFile = File('${tempDir.path}${separator}select_folder.vbs');
          await vbFile.writeAsString(vbScript);

          final result = await Process.run('cscript', [vbFile.path]);

          if (result.exitCode == 0) {
            final selectedPath = result.stdout.toString().trim();
            if (selectedPath.isNotEmpty && !selectedPath.contains('error')) {
              AppLogger.info(
                  'Répertoire sélectionné (VBScript): $selectedPath');
              try {
                await vbFile.delete();
              } catch (_) {
                // Ignorer l'erreur de suppression du fichier temporaire
              }
              return selectedPath;
            }
          }

          try {
            await vbFile.delete();
          } catch (_) {
            // Ignorer l'erreur de suppression du fichier temporaire
          }
        } catch (e) {
          AppLogger.warning('Dialogue Windows VBScript indisponible: $e');
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'ouverture du dialogue', e, stackTrace);
      return null;
    }
  }

  /// Importe les prospects depuis un fichier Excel
  Future<List<Map<String, dynamic>>> importProspectsFromExcel(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final prospects = <Map<String, dynamic>>[];

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        if (sheet.maxRows <= 1) continue;

        // On suppose que la première ligne est l'en-tête
        // Colonnes attendues: Nom, Prénom, Email, Téléphone, Adresse, Type
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          prospects.add({
            'nom': row.isNotEmpty ? row[0]?.value?.toString() ?? '' : '',
            'prenom': row.length > 1 ? row[1]?.value?.toString() ?? '' : '',
            'email': row.length > 2 ? row[2]?.value?.toString() ?? '' : '',
            'telephone': row.length > 3 ? row[3]?.value?.toString() ?? '' : '',
            'adresse': row.length > 4 ? row[4]?.value?.toString() ?? '' : '',
            'type': row.length > 5 ? row[5]?.value?.toString() ?? 'particulier' : 'particulier',
          });
        }
        break; // On ne lit que la première feuille
      }
      return prospects;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'import Excel', e);
      throw Exception('Erreur lors de l\'import du fichier Excel: $e');
    }
  }

  /// Ouvre un dialogue pour choisir un fichier à importer
  Future<String?> pickImportFile() async {
    try {
      if (Platform.isLinux) {
        final result = await Process.run('zenity', ['--file-selection', '--title=Choisir le fichier Excel à importer', '--file-filter=*.xlsx']);
        if (result.exitCode == 0) return result.stdout.toString().trim();
      } else if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-Command',
          r'[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null; $fileDialog = New-Object System.Windows.Forms.OpenFileDialog; $fileDialog.Filter = "Excel Files (*.xlsx)|*.xlsx"; if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $fileDialog.FileName }'
        ]);
        if (result.exitCode == 0) return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      AppLogger.error('Erreur lors de la sélection du fichier', e);
      return null;
    }
  }
}
