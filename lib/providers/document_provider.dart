import 'package:flutter/material.dart';
import '../models/document.dart';
import '../domain/repositories/i_document_repository.dart';
import '../utils/exception_handler.dart';
import '../core/di/service_locator.dart';

class DocumentProvider extends ChangeNotifier {
  final IDocumentRepository _repository;
  
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DocumentProvider({IDocumentRepository? repository}) 
      : _repository = repository ?? sl.documentRepository;

  Future<void> loadDocuments(int prospectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await _repository.getDocumentsByProspect(prospectId);
      _error = null;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDocument(Document document) async {
    try {
      await _repository.uploadDocument(document);
      await loadDocuments(document.idProspect);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    }
  }

  Future<bool> deleteDocument(int documentId, int prospectId) async {
    try {
      await _repository.deleteDocument(documentId);
      await loadDocuments(prospectId);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    }
  }
}
