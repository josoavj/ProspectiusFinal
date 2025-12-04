import 'package:flutter/material.dart';
import '../services/audit_service.dart';
import '../services/transfer_service.dart';
import '../services/mysql_service.dart';
import '../utils/app_logger.dart';

// Notifiers pour gérer les états d'audit et de transfert
class AuditNotifier extends ChangeNotifier {
  AuditService? _auditService;
  List<Map<String, dynamic>> _auditHistory = [];
  bool _isLoading = false;
  String? _error;

  AuditNotifier() {
    _initAuditService();
  }

  void _initAuditService() {
    try {
      final mysql = MySQLService();
      if (mysql.isConnected) {
        _auditService = AuditService(mysql.getConnection());
      }
    } catch (e) {
      AppLogger.warning('Service d\'audit non disponible: $e');
    }
  }

  List<Map<String, dynamic>> get auditHistory => _auditHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAuditHistory(int prospectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_auditService != null) {
        _auditHistory = await _auditService!.getAuditHistory(
          tableName: 'prospects',
          recordId: prospectId,
        );
      }
    } catch (e) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement de l\'historique d\'audit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class TransferNotifier extends ChangeNotifier {
  TransferService? _transferService;
  List<ProspectTransfer> _transferHistory = [];
  List<ProspectTransfer> _receivedTransfers = [];
  List<ProspectTransfer> _sentTransfers = [];
  Map<String, dynamic> _transferStats = {};
  bool _isLoading = false;
  String? _error;

  TransferNotifier() {
    _initTransferService();
  }

  void _initTransferService() {
    try {
      final mysql = MySQLService();
      if (mysql.isConnected) {
        _transferService = TransferService(mysql.getConnection());
      }
    } catch (e) {
      AppLogger.warning('Service de transfert non disponible: $e');
    }
  }

  List<ProspectTransfer> get transferHistory => _transferHistory;
  List<ProspectTransfer> get receivedTransfers => _receivedTransfers;
  List<ProspectTransfer> get sentTransfers => _sentTransfers;
  Map<String, dynamic> get transferStats => _transferStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransferHistory(int prospectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_transferService != null) {
        _transferHistory =
            await _transferService!.getProspectTransferHistory(prospectId);
      }
    } catch (e) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement de l\'historique de transfert');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReceivedTransfers(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_transferService != null) {
        _receivedTransfers =
            await _transferService!.getReceivedTransfers(userId);
      }
    } catch (e) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des transferts reçus');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSentTransfers(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_transferService != null) {
        _sentTransfers = await _transferService!.getSentTransfers(userId);
      }
    } catch (e) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des transferts envoyés');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransferStats(int userId) async {
    try {
      if (_transferService != null) {
        _transferStats = await _transferService!.getTransferStats(userId);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error(
          'Erreur lors du chargement des statistiques de transfert');
    }
  }

  Future<void> createTransfer({
    required int prospectId,
    required int fromUserId,
    required int toUserId,
    String? reason,
    String? notes,
  }) async {
    try {
      if (_transferService != null) {
        await _transferService!.createTransfer(
          prospectId: prospectId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          reason: reason,
          notes: notes,
        );
        // Rafraîchir l'historique
        await loadTransferHistory(prospectId);
        await loadTransferStats(fromUserId);
        await loadTransferStats(toUserId);
      }
    } catch (e) {
      _error = 'Erreur lors de la création du transfert: $e';
      AppLogger.error('Erreur lors de la création du transfert');
    }
    notifyListeners();
  }
}
