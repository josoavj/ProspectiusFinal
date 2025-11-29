import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prospect.dart';
import '../utils/app_logger.dart';
import '../utils/exception_handler.dart';

class ExcelService {
  Future<String> exportProspectsToExcel(
    List<Prospect> prospects, {
    required String fileName,
  }) async {
    try {
      AppLogger.info('Démarrage de l\'export Excel');

      // Créer un nouveau classeur
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // En-têtes
      final headers = [
        'ID',
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

      // Ajouter les en-têtes
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColor: ExcelColor.fromHexString("FFD3D3D3"),
          );
      }

      // Ajouter les données des prospects
      for (int row = 0; row < prospects.length; row++) {
        final prospect = prospects[row];
        final cells = [
          prospect.id.toString(),
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
          sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: row + 1,
          ))
            .value = cells[col];
        }
      }

      // Ajuster les largeurs de colonnes
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Obtenir le répertoire de téléchargement
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.xlsx';

      // Sauvegarder le fichier
      final file = File(filePath);
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }

      AppLogger.success('Fichier Excel créé: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'export Excel', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de l\'export: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }
}
