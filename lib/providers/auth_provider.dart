import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import '../services/mysql_service.dart';
import '../services/storage_service.dart';
import '../services/error_handling_service.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  Account? _currentUser;
  bool _isLoading = false;
  String? _error;

  Account? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final MySQLService _mysqlService = MySQLService();

  Future<bool> configureDatabase(MySQLConfig config) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ErrorHandlingService.executeWithTimeout(
        () => _mysqlService.connect(config),
        operationName: 'Configuration de la base de données',
        timeout: ErrorHandlingService.defaultTimeout,
      );

      _isLoading = false;
      notifyListeners();
      AppLogger.success('Base de données configurée');
      return true;
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors de la connexion', null);
      _isLoading = false;
      notifyListeners();
      return false;
    } on ConnectionException catch (e) {
      _error = e.message;
      AppLogger.error('Erreur de connexion: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur de connexion à la base de données: $e';
      AppLogger.error('Erreur de connexion à MySQL', e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_mysqlService.isConnected) {
        throw ConnectionException(
          message: 'Base de données non connectée',
          code: 'DB_NOT_CONNECTED',
        );
      }

      _currentUser = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.authenticate(username, password),
        operationName: 'Authentification',
        timeout: ErrorHandlingService.shortTimeout,
      );
      await _storageService.saveUserData(_currentUser!.username);

      _isLoading = false;
      notifyListeners();
      AppLogger.success('Connexion réussie pour ${_currentUser!.fullName}');
      return true;
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors de l\'authentification', null);
      _isLoading = false;
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur d\'authentification: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors de la connexion', e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_mysqlService.isConnected) {
        throw ConnectionException(
          message: 'Base de données non connectée',
          code: 'DB_NOT_CONNECTED',
        );
      }

      await _databaseService.createAccount(
        nom,
        prenom,
        email,
        username,
        password,
      );

      _isLoading = false;
      notifyListeners();
      AppLogger.success('Compte créé avec succès');
      return true;
    } on AppException catch (e) {
      _error = e.message;
      AppLogger.warning('Erreur lors de l\'inscription: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors de l\'inscription', e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearUserData();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _mysqlService.disconnect();
    _currentUser = null;
    notifyListeners();
  }
}
