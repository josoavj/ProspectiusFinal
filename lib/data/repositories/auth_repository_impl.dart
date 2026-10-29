import 'package:bcrypt/bcrypt.dart';
import 'dart:math';
import '../../domain/repositories/i_auth_repository.dart';
import '../../models/account.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';
import '../../utils/exception_handler.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final MySQLService _mysqlService;

  AuthRepositoryImpl(this._mysqlService);

  @override
  Future<bool> hasAccounts() async {
    final results = await _mysqlService.query('SELECT COUNT(*) AS total FROM Account');
    return (results.first['total'] as num?)?.toInt() != 0;
  }

  @override
  Future<String> createFirstAdmin(Map<String, String> data) async {
    final hasExistingAccounts = await hasAccounts();
    if (hasExistingAccounts) {
      throw AuthException(
        message: 'Un administrateur existe déjà pour cette base de données.',
        code: 'ADMIN_ALREADY_INITIALIZED',
      );
    }

    final passwordHash = BCrypt.hashpw(data['password']!, BCrypt.gensalt());
    final recoveryCode = _generateRecoveryCode();
    final recoveryHash = BCrypt.hashpw(recoveryCode, BCrypt.gensalt());
    await _mysqlService.query(
      SqlQueries.insertAccount,
      [
        data['nom'],
        data['prenom'],
        data['email'],
        data['username'],
        passwordHash,
        'Administrateur',
      ],
    );
    await _mysqlService.query(
      'INSERT INTO AdminRecovery (email, code_hash) VALUES (?, ?)',
      [data['email'], recoveryHash],
    );
    return recoveryCode;
  }

  String _generateRecoveryCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      24,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  @override
  Future<Account> authenticate(String username, String password) async {
    final results = await _mysqlService.query(
      SqlQueries.findUserByUsername,
      [username],
    );

    if (results.isEmpty) {
      throw AuthException(message: 'Utilisateur non trouvé', code: 'USER_NOT_FOUND');
    }

    final row = results.first;
    final hashedPassword = row['password'] as String;

    if (!BCrypt.checkpw(password, hashedPassword)) {
      throw AuthException(message: 'Mot de passe incorrect', code: 'INVALID_PASSWORD');
    }

    return Account.fromJson(row.fields);
  }

  @override
  Future<void> createAccount(Map<String, String> data) async {
    final passwordHash = BCrypt.hashpw(data['password']!, BCrypt.gensalt());
    
    await _mysqlService.query(
      SqlQueries.insertAccount,
      [
        data['nom'],
        data['prenom'],
        data['email'],
        data['username'],
        passwordHash,
        'Utilisateur',
      ],
    );
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    final results = await _mysqlService.query('SELECT * FROM Account ORDER BY nom, prenom');
    return results.map((row) => Account.fromJson(row.fields)).toList();
  }

  @override
  Future<void> updateAccountRole(int accountId, String role) async {
    if (!const ['Administrateur', 'Utilisateur', 'Commercial'].contains(role)) {
      throw AuthException(message: 'Rôle invalide.', code: 'INVALID_ROLE');
    }

    if (role != 'Administrateur') {
      final admins = await _mysqlService.query(
        'SELECT COUNT(*) AS total FROM Account WHERE type_compte = ?',
        ['Administrateur'],
      );
      if ((admins.first['total'] as num).toInt() <= 1) {
        final current = await _mysqlService.query(
          'SELECT type_compte FROM Account WHERE id_compte = ?',
          [accountId],
        );
        if (current.isNotEmpty && current.first['type_compte'] == 'Administrateur') {
          throw AuthException(
            message: 'Le dernier administrateur ne peut pas être rétrogradé.',
            code: 'LAST_ADMIN',
          );
        }
      }
    } else {
      final admins = await _mysqlService.query(
        'SELECT COUNT(*) AS total FROM Account WHERE type_compte = ?',
        ['Administrateur'],
      );
      if ((admins.first['total'] as num).toInt() >= 3) {
        throw AuthException(
          message: 'La limite de 3 administrateurs est atteinte.',
          code: 'ADMIN_LIMIT',
        );
      }
    }
    await _mysqlService.query(
      'UPDATE Account SET type_compte = ? WHERE id_compte = ?',
      [role, accountId],
    );
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    final target = await _mysqlService.query(
      'SELECT type_compte FROM Account WHERE id_compte = ?',
      [accountId],
    );
    if (target.isEmpty) {
      throw AuthException(message: 'Compte introuvable.', code: 'ACCOUNT_NOT_FOUND');
    }
    if (target.first['type_compte'] == 'Administrateur') {
      final admins = await _mysqlService.query(
        'SELECT COUNT(*) AS total FROM Account WHERE type_compte = ?',
        ['Administrateur'],
      );
      if ((admins.first['total'] as num).toInt() <= 1) {
        throw AuthException(
          message: 'Le dernier administrateur ne peut pas être supprimé.',
          code: 'LAST_ADMIN',
        );
      }
    }
    await _mysqlService.query(
      'DELETE FROM Account WHERE id_compte = ?',
      [accountId],
    );
  }

  @override
  Future<void> updatePassword(int userId, String newPassword) async {
    final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    await _mysqlService.query(
      'UPDATE Account SET password = ? WHERE id_compte = ?',
      [passwordHash, userId],
    );
  }

  @override
  Future<Account> resetPasswordWithRecoveryCode(
    String email,
    String recoveryCode,
    String newPassword,
  ) async {
    final results = await _mysqlService.query(
      'SELECT a.*, r.code_hash FROM Account a JOIN AdminRecovery r ON r.email = a.email WHERE a.email = ? AND a.type_compte = ? AND r.used_at IS NULL',
      [email, 'Administrateur'],
    );
    if (results.isEmpty || !BCrypt.checkpw(recoveryCode, results.first['code_hash'] as String)) {
      throw AuthException(
        message: 'Adresse e-mail ou code de récupération incorrect.',
        code: 'INVALID_RECOVERY',
      );
    }

    final userId = results.first['id_compte'];
    final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    await _mysqlService.query(
      'UPDATE Account SET password = ? WHERE id_compte = ?',
      [passwordHash, userId],
    );
    await _mysqlService.query(
      'UPDATE AdminRecovery SET used_at = NOW() WHERE email = ?',
      [email],
    );
    return Account.fromJson(results.first.fields);
  }

  @override
  Future<String> regenerateAdminRecoveryCode(
    String email,
    String currentPassword,
  ) async {
    final results = await _mysqlService.query(
      'SELECT a.*, r.id AS recovery_id FROM Account a '
      'LEFT JOIN AdminRecovery r ON r.email = a.email '
      'WHERE a.email = ? AND a.type_compte = ?',
      [email, 'Administrateur'],
    );
    if (results.isEmpty ||
        !BCrypt.checkpw(currentPassword, results.first['password'] as String)) {
      throw AuthException(
        message: 'Mot de passe administrateur incorrect.',
        code: 'INVALID_ADMIN_PASSWORD',
      );
    }

    final recoveryCode = _generateRecoveryCode();
    final recoveryHash = BCrypt.hashpw(recoveryCode, BCrypt.gensalt());
    final recoveryId = results.first['recovery_id'];
    if (recoveryId == null) {
      await _mysqlService.query(
        'INSERT INTO AdminRecovery (email, code_hash, used_at) VALUES (?, ?, NULL)',
        [email, recoveryHash],
      );
    } else {
      await _mysqlService.query(
        'UPDATE AdminRecovery SET code_hash = ?, used_at = NULL, created_at = CURRENT_TIMESTAMP WHERE id = ?',
        [recoveryHash, recoveryId],
      );
    }
    return recoveryCode;
  }
}
