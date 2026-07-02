import 'package:flutter/material.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../domain/repositories/i_prospect_repository.dart';
import '../utils/exception_handler.dart';
import '../core/di/service_locator.dart';

class ProspectProvider extends ChangeNotifier {
  final IProspectRepository _repository;
  
  List<Prospect> _prospects = [];
  final List<Interaction> _interactions = [];
  bool _isLoading = false;
  String? _error;
  Prospect? _selectedProspect;

  List<Prospect> get prospects => _prospects;
  List<Interaction> get interactions => _interactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Prospect? get selectedProspect => _selectedProspect;

  ProspectProvider({IProspectRepository? repository}) 
      : _repository = repository ?? sl.prospectRepository;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> loadProspects(int userId, String userRole, {bool refresh = true}) async {
    if (refresh) {
      _currentPage = 0;
      _prospects = [];
      _hasMore = true;
    }
    
    if (!_hasMore && !refresh) return;

    _setLoading(true);
    try {
      final newProspects = await _repository.getProspects(
        userId, 
        userRole,
        limit: _pageSize, 
        offset: _currentPage * _pageSize
      );
      
      if (newProspects.length < _pageSize) {
        _hasMore = false;
      }
      
      _prospects.addAll(newProspects);
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = _formatError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProspect(Map<String, dynamic> data, String userRole) async {
    _setLoading(true);
    try {
      await _repository.createProspect(data);
      if (data.containsKey('userId')) {
        await loadProspects(data['userId'] as int, userRole);
      }
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProspect(int userId, String userRole, int prospectId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _repository.updateProspect(prospectId, data);
      await loadProspects(userId, userRole);
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProspect(int userId, String userRole, int prospectId) async {
    try {
      await _repository.deleteProspect(prospectId);
      await loadProspects(userId, userRole);
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    }
  }

  Future<bool> updateProspectStatus(int userId, String userRole, int prospectId, String newStatus) async {
    try {
      await _repository.updateProspect(prospectId, {'status': newStatus});
      await loadProspects(userId, userRole);
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    }
  }

  Future<void> loadInteractions(int prospectId) async {
    _setLoading(true);
    try {
      final results = await _repository.getInteractions(prospectId);
      _interactions.clear();
      _interactions.addAll(results);
      _error = null;
    } catch (e) {
      _error = _formatError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createInteraction(int prospectId, int userId, String type, String note, DateTime date) async {
    try {
      await _repository.createInteraction({
        'prospectId': prospectId,
        'userId': userId,
        'type': type,
        'note': note,
        'dateInteraction': date,
      });
      await loadInteractions(prospectId);
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    }
  }

  Future<bool> createInteractionComplex({
    required int prospectId,
    required int userId,
    required String userRole,
    required String type,
    required String note,
    required DateTime date,
    int? idAssigne,
    String? suivi,
    String? newStatus,
  }) async {
    try {
      await _repository.createInteraction({
        'prospectId': prospectId,
        'userId': userId,
        'idAssigne': idAssigne,
        'type': type,
        'note': note,
        'suivi': suivi,
        'dateInteraction': date,
        'newStatus': newStatus,
      });
      await loadInteractions(prospectId);
      await loadProspects(userId, userRole); // Rafraîchir pour voir le nouveau statut
      return true;
    } catch (e) {
      _error = _formatError(e);
      return false;
    }
  }

  String _formatError(dynamic e) {
    if (e is Exception) {
      return ExceptionHandler.getErrorMessage(e);
    }
    return 'Une erreur inattendue est survenue: $e';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void selectProspect(Prospect prospect) {
    _selectedProspect = prospect;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
