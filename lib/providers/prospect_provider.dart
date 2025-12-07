import 'package:flutter/material.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../services/database_service.dart';
import '../services/error_handling_service.dart';
import '../services/audit_service.dart';
import '../services/transfer_service.dart';
import '../services/mysql_service.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

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
  AuditService? _auditService;
  TransferService? _transferService;

  ProspectProvider() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      final mysql = MySQLService();
      if (mysql.isConnected) {
        final connection = mysql.getConnection();
        _auditService = AuditService(connection);
        _transferService = TransferService(connection);
      }
    } catch (e) {
      AppLogger.warning('Services d\'audit/transfert non disponibles: $e');
    }
  }

  Future<void> loadProspects(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prospects = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getProspects(userId),
        operationName: 'Chargement des prospects',
        timeout: ErrorHandlingService.defaultTimeout,
      );
      AppLogger.success('${_prospects.length} prospect(s) chargé(s)');
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors du chargement', null);
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning(
          'Erreur lors du chargement des prospects: ${e.message}');
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des prospects', e, stackTrace);
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
    String adresse,
    String type,
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
        adresse,
        type,
      );

      await loadProspects(userId);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors de la création: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors de la création du prospect', e, stackTrace);
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
      await loadProspects(userId);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors de la mise à jour: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors de la mise à jour du prospect', e, stackTrace);
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

      // Enregistrer l'audit
      if (_auditService != null) {
        await _auditService!.logProspectDeletion(
          prospectId: prospectId,
          userId: userId,
        );
      }

      await loadProspects(userId);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors de la suppression: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors de la suppression du prospect', e, stackTrace);
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
      AppLogger.success('${_interactions.length} interaction(s) chargée(s)');
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning(
          'Erreur lors du chargement des interactions: ${e.message}');
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement des interactions', e, stackTrace);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createInteraction(
    int prospectId,
    int userId,
    String type,
    String note,
    DateTime dateInteraction,
  ) async {
    try {
      await _databaseService.createInteraction(
        prospectId,
        userId,
        type,
        note,
        dateInteraction,
      );

      await loadInteractions(prospectId);
      AppLogger.success('Interaction créée avec succès');
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors de la création: ${e.message}');
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors de la création de l\'interaction', e, stackTrace);
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

  /// Transfère un prospect d'un utilisateur à un autre
  Future<bool> transferProspect({
    required int prospectId,
    required int fromUserId,
    required int toUserId,
    String? reason,
    String? notes,
  }) async {
    try {
      if (_transferService == null) {
        _error = 'Service de transfert non disponible';
        notifyListeners();
        return false;
      }

      await _transferService!.createTransfer(
        prospectId: prospectId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        reason: reason,
        notes: notes,
      );

      // Enregistrer l'audit
      if (_auditService != null) {
        await _auditService!.logAudit(
          tableName: 'Prospect',
          recordId: prospectId,
          action: 'UPDATE',
          userId: fromUserId,
          description: 'Prospect transféré à User #$toUserId',
        );
      }

      AppLogger.success('Prospect transféré avec succès');
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors du transfert: ${e.message}');
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du transfert du prospect', e, stackTrace);
      notifyListeners();
      return false;
    }
  }
}
