import 'package:flutter/material.dart';
import '../models/account.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../services/mysql_service.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';
import '../core/di/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final MySQLService _mysqlService;
  
  Account? _currentUser;
  bool _isLoading = false;
  String? _error;

  Account? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({IAuthRepository? authRepository, MySQLService? mysqlService})
      : _authRepository = authRepository ?? sl.authRepository,
        _mysqlService = mysqlService ?? sl.mysqlService;

  Future<bool> configureDatabase(MySQLConfig config) async {
    _setLoading(true);
    try {
      final success = await _mysqlService.connect(config);
      if (success) AppLogger.success('Base de données connectée');
      return success;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authRepository.authenticate(username, password);
      AppLogger.success('Utilisateur connecté: ${_currentUser!.username}');
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
    String typeCompte,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.createAccount({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'username': username,
        'password': password,
        'type_compte': typeCompte,
      });
      AppLogger.success('Compte créé avec succès');
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<Account>> getAllUsers() async {
    try {
      return await _authRepository.getAllAccounts();
    } catch (e) {
      AppLogger.error('Erreur récupération utilisateurs', e);
      return [];
    }
  }
}
