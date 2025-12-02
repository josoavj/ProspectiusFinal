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
      AppLogger.info('Démarrage de l\'export Excel');

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
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: '4472C4',
            fontColorHex: 'FFFFFF',
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
          cell.value = cells[col];

          // Ajouter la couleur de background selon le statut (colonne 6 = statut)
          if (col == 6) {
            cell.cellStyle = CellStyle(
              backgroundColorHex: _getStatusColor(prospect.status),
              fontColorHex: 'FFFFFF',
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
        final dir = Directory(directoryPath);
        if (!await dir.exists()) {
          throw Exception(
              'Le répertoire spécifié n\'existe pas: $directoryPath');
        }
        savePath = '$directoryPath/$fileName.xlsx';
      } else {
        // Utiliser le répertoire de documents par défaut
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName.xlsx';
      }

      // Sauvegarder le fichier
      final file = File(savePath);
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }

      AppLogger.success('Fichier Excel créé: $savePath');
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
      ..value = 'STATISTIQUES'
      ..cellStyle = CellStyle(bold: true);
    row += 2;

    // Total prospects
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Total prospects'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = prospects.length;
    row += 2;

    // Statistiques par statut
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Par statut'
      ..cellStyle = CellStyle(bold: true);
    row += 1;

    final statusMap = <String, int>{};
    for (final prospect in prospects) {
      statusMap[prospect.status] = (statusMap[prospect.status] ?? 0) + 1;
    }

    for (final status in [
      'nouveau',
      'interesse',
      'negociation',
      'converti',
      'perdu'
    ]) {
      if (statusMap.containsKey(status)) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = _formatStatus(status);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = statusMap[status];
        row += 1;
      }
    }

    row += 2;

    // Statistiques par mois
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Par mois'
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
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = month;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = monthMap[month];
      row += 1;
    }

    row += 2;

    // Statistiques par type
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Par type'
      ..cellStyle = CellStyle(bold: true);
    row += 1;

    final typeMap = <String, int>{};
    for (final prospect in prospects) {
      typeMap[prospect.type] = (typeMap[prospect.type] ?? 0) + 1;
    }

    for (final entry in typeMap.entries) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = _formatType(entry.key);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = entry.value;
      row += 1;
    }

    row += 2;

    // Performances
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'PERFORMANCES'
      ..cellStyle = CellStyle(bold: true);
    row += 2;

    // Taux de conversion
    final convertis = statusMap['converti'] ?? 0;
    final tauxConversion =
        prospects.isEmpty ? 0.0 : (convertis / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Taux de conversion'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = '${tauxConversion.toStringAsFixed(2)}%';
    row += 1;

    // Taux de perte
    final perdus = statusMap['perdu'] ?? 0;
    final tauxPerte =
        prospects.isEmpty ? 0.0 : (perdus / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Taux de perte'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = '${tauxPerte.toStringAsFixed(2)}%';
    row += 1;

    // Taux d'engagement (interessé + en négociation)
    final engages =
        (statusMap['interesse'] ?? 0) + (statusMap['negociation'] ?? 0);
    final tauxEngagement =
        prospects.isEmpty ? 0.0 : (engages / prospects.length) * 100;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Taux d\'engagement'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = '${tauxEngagement.toStringAsFixed(2)}%';
    row += 1;

    // Prospects en attente (non convertis et non perdus)
    final enAttente = prospects.length - convertis - perdus;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Prospects en attente'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = enAttente;
    row += 2;

    // Moyenne de prospects par mois
    final moyenneParMois =
        monthMap.isEmpty ? 0.0 : prospects.length / monthMap.length;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = 'Moyenne de prospects/mois'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = moyenneParMois.toStringAsFixed(2);
    row += 1;

    // Prospect le plus récent
    if (prospects.isNotEmpty) {
      final plusRecent =
          prospects.reduce((a, b) => a.creation.isAfter(b.creation) ? a : b);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = 'Prospect le plus récent'
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = _formatMonth(plusRecent.creation);
      row += 1;
    }

    // Prospect le plus ancien
    if (prospects.isNotEmpty) {
      final plusAncien =
          prospects.reduce((a, b) => a.creation.isBefore(b.creation) ? a : b);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = 'Prospect le plus ancien'
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = _formatMonth(plusAncien.creation);
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

  /// Retourne la couleur hexadécimale selon le statut
  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau':
        return '4472C4'; // Bleu
      case 'interesse':
        return 'FFC000'; // Orange
      case 'negociation':
        return 'FF8C00'; // Orange foncé
      case 'converti':
        return '70AD47'; // Vert
      case 'perdu':
        return 'C5504B'; // Rouge
      default:
        return '808080'; // Gris
    }
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
        // Sur Windows
        try {
          final result = await Process.run(
            'powershell',
            [
              '-Command',
              '[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null; (New-Object System.Windows.Forms.FolderBrowserDialog).ShowDialog()',
            ],
          );

          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          }
        } catch (e) {
          AppLogger.warning('Dialogue Windows indisponible');
          return null;
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'ouverture du dialogue', e, stackTrace);
      return null;
    }
  }
}
