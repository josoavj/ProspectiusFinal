import '../../models/account.dart';

abstract class IAuthRepository {
  Future<Account> authenticate(String username, String password);
  Future<void> createAccount(Map<String, String> data);
  Future<List<Account>> getAllAccounts();
}
