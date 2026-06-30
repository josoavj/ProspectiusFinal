import 'package:bcrypt/bcrypt.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../models/account.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';
import '../../utils/exception_handler.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final MySQLService _mysqlService;

  AuthRepositoryImpl(this._mysqlService);

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
        data['type_compte'] ?? 'Utilisateur',
      ],
    );
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    final results = await _mysqlService.query('SELECT * FROM Account ORDER BY nom, prenom');
    return results.map((row) => Account.fromJson(row.fields)).toList();
  }
}
