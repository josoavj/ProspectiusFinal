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

  Future<bool> hasAccounts() => _authRepository.hasAccounts();

  Future<String?> registerFirstAdmin(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final recoveryCode = await _authRepository.createFirstAdmin({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'username': username,
        'password': password,
      });
      AppLogger.success('Premier administrateur créé');
      return recoveryCode;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPasswordWithRecoveryCode(
    String email,
    String recoveryCode,
    String newPassword,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authRepository.resetPasswordWithRecoveryCode(
        email,
        recoveryCode,
        newPassword,
      );
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> regenerateAdminRecoveryCode(String currentPassword) async {
    final user = _currentUser;
    if (user == null || user.typeCompte != 'Administrateur') {
      _error = 'Cette action est réservée aux administrateurs.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _error = null;
    try {
      final code = await _authRepository.regenerateAdminRecoveryCode(
        user.email,
        currentPassword,
      );
      AppLogger.success('Code de récupération administrateur régénéré');
      return code;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return null;
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

  Future<bool> updateUserRole(
    int accountId,
    String role,
    String adminPassword,
  ) async {
    if (_currentUser?.typeCompte != 'Administrateur') {
      _error = 'Cette action est réservée aux administrateurs.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _error = null;
    try {
      await _verifyAdminPassword(adminPassword);
      await _authRepository.updateAccountRole(accountId, role);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(int accountId, String adminPassword) async {
    final user = _currentUser;
    if (user == null || user.typeCompte != 'Administrateur') {
      _error = 'Cette action est réservée aux administrateurs.';
      notifyListeners();
      return false;
    }
    if (accountId == user.id) {
      _error = 'Vous ne pouvez pas supprimer votre propre compte.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _error = null;
    try {
      await _verifyAdminPassword(adminPassword);
      await _authRepository.deleteAccount(accountId);
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _verifyAdminPassword(String password) async {
    final user = _currentUser;
    if (user == null || password.isEmpty) {
      throw AuthException(
        message: 'Le mot de passe administrateur est obligatoire.',
        code: 'PASSWORD_REQUIRED',
      );
    }
    try {
      await _authRepository.authenticate(user.username, password);
    } catch (_) {
      throw AuthException(
        message: 'Mot de passe administrateur incorrect.',
        code: 'INVALID_ADMIN_PASSWORD',
      );
    }
  }

  Future<bool> verifyCurrentPassword(String password) async {
    if (_currentUser == null) return false;
    try {
      await _authRepository.authenticate(_currentUser!.username, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(int userId, String currentPassword, String newPassword) async {
    _setLoading(true);
    _error = null;
    try {
      // 1. Vérifier le mot de passe actuel
      if (_currentUser == null) throw AuthException(message: 'Non authentifié', code: 'UNAUTHORIZED');
      
      try {
        await _authRepository.authenticate(_currentUser!.username, currentPassword);
      } catch (e) {
        throw AuthException(message: 'Le mot de passe actuel est incorrect', code: 'INVALID_CURRENT_PASSWORD');
      }

      // 2. Mettre à jour avec le nouveau
      await _authRepository.updatePassword(userId, newPassword);
      AppLogger.success('Mot de passe mis à jour avec succès');
      return true;
    } catch (e) {
      _error = ExceptionHandler.getErrorMessage(e as Exception);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
