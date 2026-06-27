import '../../models/document.dart';

abstract class IDocumentRepository {
  Future<List<Document>> getDocumentsByProspect(int prospectId);
  Future<void> uploadDocument(Document document);
  Future<void> deleteDocument(int documentId);
}
