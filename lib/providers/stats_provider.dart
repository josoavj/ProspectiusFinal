import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  List<ProspectStats> _prospectStats = [];
  ConversionStats? _conversionStats;
  bool _isLoading = false;
  String? _error;

  List<ProspectStats> get prospectStats => _prospectStats;
  ConversionStats? get conversionStats => _conversionStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadProspectStats(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prospectStats = await _databaseService.getProspectStats(userId);
    } catch (e) {
      _error = 'Erreur: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadConversionStats(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversionStats = await _databaseService.getConversionStats(userId);
    } catch (e) {
      _error = 'Erreur: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
