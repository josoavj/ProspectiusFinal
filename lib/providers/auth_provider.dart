import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import '../services/mysql_service.dart';
import '../services/storage_service.dart';

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
    try {
      _isLoading = true;
      notifyListeners();

      await _mysqlService.connect(config);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur de connexion à la base de données: $e';
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
        _error = 'Base de données non connectée';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _databaseService.authenticate(username, password);

      if (result['success']) {
        _currentUser = result['user'];
        await _storageService.saveUserData(_currentUser!.username);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur: $e';
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
        _error = 'Base de données non connectée';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _databaseService.createAccount(
        nom,
        prenom,
        email,
        username,
        password,
      );

      _isLoading = false;
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur: $e';
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
