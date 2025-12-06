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
  int _loadingCount = 0;

  List<ProspectStats> get prospectStats => _prospectStats;
  ConversionStats? get conversionStats => _conversionStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseService _databaseService = DatabaseService();

  void _setLoading(bool loading) {
    if (loading) {
      _loadingCount++;
    } else {
      _loadingCount--;
    }
    _isLoading = _loadingCount > 0;
    notifyListeners();
  }

  Future<void> loadAllStats(int userId) async {
    _error = null;
    _setLoading(true);

    try {
      AppLogger.info('Démarrage du chargement des stats pour user: $userId');
      final results = await Future.wait([
        ErrorHandlingService.executeWithTimeout(
          () => _databaseService.getProspectStats(userId),
          operationName: 'Chargement des statistiques',
          timeout: const Duration(seconds: 30), // Augmenté de 15 à 30 secondes
        ),
        ErrorHandlingService.executeWithTimeout(
          () => _databaseService.getConversionStats(userId),
          operationName: 'Chargement des statistiques de conversion',
          timeout: const Duration(seconds: 30), // Augmenté de 15 à 30 secondes
        ),
      ]);

      _prospectStats = results[0] as List<ProspectStats>;
      _conversionStats = results[1] as ConversionStats;
      AppLogger.success(
          'Stats chargées avec succès: ${_prospectStats.length} statuts, taux: ${_conversionStats?.conversionRate}');
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error(
          'Timeout lors du chargement des stats: ${e.message}', null);
      notifyListeners(); // S'assurer que les listeners sont notifiés même en cas d'erreur
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des stats', e, stackTrace);
      notifyListeners(); // S'assurer que les listeners sont notifiés même en cas d'erreur
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProspectStats(int userId) async {
    _error = null;
    _setLoading(true);

    try {
      _prospectStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getProspectStats(userId),
        operationName: 'Chargement des statistiques',
        timeout: const Duration(seconds: 30), // Augmenté de 15 à 30 secondes
      );
      AppLogger.success('Stats prospects chargées: ${_prospectStats.length}');
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors du chargement des stats', null);
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des stats', e, stackTrace);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadConversionStats(int userId) async {
    _error = null;
    _setLoading(true);

    try {
      _conversionStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getConversionStats(userId),
        operationName: 'Chargement des statistiques de conversion',
        timeout: const Duration(seconds: 30), // Augmenté de 15 à 30 secondes
      );
      AppLogger.success(
          'Stats conversion chargées: ${_conversionStats?.conversionRate}');
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error(
          'Timeout lors du chargement des stats de conversion', null);
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement des stats de conversion', e, stackTrace);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
