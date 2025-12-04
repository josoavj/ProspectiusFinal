import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/database_service.dart';
import '../services/error_handling_service.dart';
import '../utils/app_logger.dart';

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
      _prospectStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getProspectStats(userId),
        operationName: 'Chargement des statistiques',
        timeout: ErrorHandlingService.defaultTimeout,
      );
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors du chargement des stats', null);
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des stats', e, stackTrace);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadConversionStats(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversionStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getConversionStats(userId),
        operationName: 'Chargement des statistiques de conversion',
        timeout: ErrorHandlingService.defaultTimeout,
      );
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error(
          'Timeout lors du chargement des stats de conversion', null);
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement des stats de conversion', e, stackTrace);
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
