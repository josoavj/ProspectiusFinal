import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class RecoveryCodeExportService {
  static Future<Uri?> save(String code) {
    final content = '''
Prospectius - Code de récupération administrateur

Code : $code

Conservez ce fichier dans un emplacement sécurisé, hors de l'application.
Ne partagez jamais ce code.
Le code est à usage unique et sera invalidé après une récupération réussie.
La génération d'un nouveau code invalide immédiatement le précédent.
''';

    return FilePicker.saveFile(
      fileName: 'prospectius-code-recuperation.txt',
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: 'text/plain',
      dialogTitle: 'Enregistrer le code de récupération',
    );
  }
}
