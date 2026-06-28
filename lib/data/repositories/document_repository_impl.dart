import '../../domain/repositories/i_document_repository.dart';
import '../../models/document.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  final MySQLService _mysqlService;

  DocumentRepositoryImpl(this._mysqlService);

  @override
  Future<List<Document>> getDocumentsByProspect(int prospectId) async {
    final results = await _mysqlService.query(
      SqlQueries.selectDocumentsByProspectId,
      [prospectId],
    );

    return results.map((row) => Document.fromJson(row.fields)).toList();
  }

  @override
  Future<void> uploadDocument(Document document) async {
    await _mysqlService.query(
      SqlQueries.insertDocument,
      [
        document.idProspect,
        document.name,
        document.filePath,
        document.mimeType,
        document.size,
      ],
    );
  }

  @override
  Future<void> deleteDocument(int documentId) async {
    await _mysqlService.query(
      'DELETE FROM documents WHERE id_document = ?',
      [documentId],
    );
  }
}
