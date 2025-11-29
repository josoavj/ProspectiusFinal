import 'package:flutter/material.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../services/database_service.dart';

class ProspectProvider extends ChangeNotifier {
  List<Prospect> _prospects = [];
  List<Interaction> _interactions = [];
  bool _isLoading = false;
  String? _error;
  Prospect? _selectedProspect;

  List<Prospect> get prospects => _prospects;
  List<Interaction> get interactions => _interactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Prospect? get selectedProspect => _selectedProspect;

  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadProspects(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prospects = await _databaseService.getProspects(userId);
    } catch (e) {
      _error = 'Erreur: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProspect(
    int userId,
    String nom,
    String prenom,
    String email,
    String telephone,
    String entreprise,
    String poste,
    String statut,
    String source,
    String notes,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.createProspect(
        userId,
        nom,
        prenom,
        email,
        telephone,
        entreprise,
        poste,
        statut,
        source,
        notes,
      );

      _isLoading = false;
      await loadProspects(userId);
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProspect(
    int userId,
    int prospectId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateProspect(prospectId, data);
      _isLoading = false;
      await loadProspects(userId);
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProspect(int userId, int prospectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteProspect(prospectId);
      _isLoading = false;
      await loadProspects(userId);
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadInteractions(int prospectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _interactions = await _databaseService.getInteractions(prospectId);
    } catch (e) {
      _error = 'Erreur: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createInteraction(
    int prospectId,
    int userId,
    String typeInteraction,
    String description,
    DateTime dateInteraction,
  ) async {
    try {
      await _databaseService.createInteraction(
        prospectId,
        userId,
        typeInteraction,
        description,
        dateInteraction,
      );

      await loadInteractions(prospectId);
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return false;
    }
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
