import '../../models/account.dart';

abstract class IAuthRepository {
  Future<Account> authenticate(String username, String password);
  Future<bool> hasAccounts();
  Future<String> createFirstAdmin(Map<String, String> data);
  Future<void> createAccount(Map<String, String> data);
  Future<Account> resetPasswordWithRecoveryCode(
    String email,
    String recoveryCode,
    String newPassword,
  );
  Future<String> regenerateAdminRecoveryCode(
    String email,
    String currentPassword,
  );
  Future<List<Account>> getAllAccounts();
  Future<void> updateAccountRole(int accountId, String role);
  Future<void> deleteAccount(int accountId);
  Future<void> updatePassword(int userId, String newPassword);
}
