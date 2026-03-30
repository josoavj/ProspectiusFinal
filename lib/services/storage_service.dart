import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'user_data';

  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // User Data
  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Clear all
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    const preserveKeys = <String>{
      'db_host',
      'db_port',
      'db_user',
      'db_name',
      'db_configured',
      'mysql_config',
    };

    final keys = prefs.getKeys();
    for (final key in keys) {
      if (!preserveKeys.contains(key)) {
        await prefs.remove(key);
      }
    }
  }
}
