import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _dbPasswordKey = 'db_password_secure';

  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveDbPassword(String password) async {
    await _storage.write(key: _dbPasswordKey, value: password);
  }

  Future<String?> getDbPassword() async {
    return _storage.read(key: _dbPasswordKey);
  }

  Future<void> clearDbPassword() async {
    await _storage.delete(key: _dbPasswordKey);
  }
}
