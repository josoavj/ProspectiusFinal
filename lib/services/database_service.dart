import 'package:bcrypt/bcrypt.dart';
import 'mysql_service.dart';
import '../models/account.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../models/stats.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';
import '../utils/validators.dart';

class DatabaseService {
  final MySQLService _mysqlService = MySQLService();

  // === AUTHENTIFICATION ===

  Future<Account> authenticate(
    String username,
    String password,
  ) async {
    try {
      AppLogger.logRequest(
          'AUTH', 'SELECT * FROM Account WHERE username = ?', [username]);

      final results = await _mysqlService.query(
        'SELECT * FROM Account WHERE username = ?',
        [username],
      );

      if (results.isEmpty) {
        AppLogger.warning(
            'Tentative d\'authentification: utilisateur "$username" non trouvé');
        throw AuthException(
          message: 'Utilisateur non trouvé',
          code: 'USER_NOT_FOUND',
        );
      }

      final row = results.first;
      final hashedPassword = row['password'] as String;

      // Vérifier le mot de passe avec bcrypt
      final isPasswordValid = BCrypt.checkpw(password, hashedPassword);

      if (!isPasswordValid) {
        AppLogger.warning(
            'Tentative d\'authentification: mot de passe incorrect pour "$username"');
        throw AuthException(
          message: 'Mot de passe incorrect',
          code: 'INVALID_PASSWORD',
        );
      }

      final user = Account(
        id: (row['id_compte'] as num).toInt(),
        nom: row['nom'] as String,
        prenom: row['prenom'] as String,
        email: row['email'] as String,
        username: row['username'] as String,
        typeCompte: row['type_compte'] as String,
        dateCreation: DateTime.parse(row['date_creation'].toString()),
      );

      AppLogger.success('Authentification réussie pour ${user.fullName}');
      return user;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'authentification', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de l\'authentification: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createAccount(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
  ) async {
    try {
      // Valider les données
      final validationResult = Validators.validateRegistration(
        nom: nom,
        prenom: prenom,
        email: email,
        username: username,
        password: password,
      );

      if (!validationResult.isValid) {
        throw ValidationException(
          message: validationResult.error!,
          code: 'INVALID_INPUT',
        );
      }

      AppLogger.logRequest('REGISTER',
          'SELECT id_compte FROM Account WHERE username = ?', [username]);

      // Vérifier l'unicité du username
      final existingUser = await _mysqlService.query(
        'SELECT id_compte FROM Account WHERE username = ?',
        [username],
      );

      if (existingUser.isNotEmpty) {
        AppLogger.warning(
            'Tentative de création: utilisateur "$username" existe déjà');
        throw ValidationException(
          message: 'Cet identifiant existe déjà',
          code: 'USERNAME_EXISTS',
        );
      }

      // Hacher le mot de passe avec bcrypt
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      AppLogger.logRequest(
        'REGISTER',
        'INSERT INTO Account',
        [nom, prenom, email, username, '***', 'Utilisateur'],
      );

      // Insérer le nouvel utilisateur
      await _mysqlService.query(
        '''INSERT INTO Account (nom, prenom, email, username, password, type_compte, date_creation)
           VALUES (?, ?, ?, ?, ?, ?, NOW())''',
        [nom, prenom, email, username, passwordHash, 'Utilisateur'],
      );

      AppLogger.success('Compte créé avec succès pour $username');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du compte', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création du compte: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === PROSPECTS ===

  Future<List<Prospect>> getProspects(int userId) async {
    try {
      AppLogger.logRequest('PROSPECTS',
          'SELECT * FROM Prospect WHERE assignation = ?', [userId]);

      final results = await _mysqlService.query(
        'SELECT * FROM Prospect WHERE assignation = ? ORDER BY creation DESC',
        [userId],
      );

      AppLogger.logResponse('PROSPECTS', results.length);

      return results
          .map(
            (row) => Prospect(
              id: (row['id_prospect'] as num).toInt(),
              nom: row['nomp'] as String? ?? '',
              prenom: row['prenomp'] as String? ?? '',
              email: row['email'] as String? ?? '',
              telephone: row['telephone'] as String? ?? '',
              adresse: row['adresse'] as String? ?? '',
              type: row['type'] as String? ?? '',
              status: row['status'] as String? ?? 'nouveau',
              creation: DateTime.parse(row['creation'].toString()),
              dateUpdate: DateTime.parse(row['date_update'].toString()),
              assignation: (row['assignation'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des prospects', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la récupération des prospects: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createProspect(
    int userId,
    String nom,
    String prenom,
    String email,
    String telephone,
    String adresse,
    String type,
  ) async {
    try {
      // Valider les données
      final validationResult = Validators.validateName(nom, 'Nom');
      if (!validationResult.isValid) {
        throw ValidationException(
          message: validationResult.error!,
          code: 'INVALID_INPUT',
        );
      }

      AppLogger.logRequest('CREATE_PROSPECT', 'INSERT INTO Prospect', [
        nom,
        prenom,
        email,
        telephone,
        adresse,
        type,
        userId,
      ]);

      await _mysqlService.query(
        '''INSERT INTO Prospect 
           (nomp, prenomp, email, telephone, adresse, type, assignation, status, creation, date_update)
           VALUES (?, ?, ?, ?, ?, ?, ?, 'nouveau', NOW(), NOW())''',
        [
          nom,
          prenom,
          email,
          telephone,
          adresse,
          type,
          userId,
        ],
      );

      AppLogger.success('Prospect "$prenom $nom" créé avec succès');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateProspect(int prospectId, Map<String, dynamic> data) async {
    try {
      final updates = <String>[];
      final values = <dynamic>[];

      data.forEach((key, value) {
        if (key != 'id') {
          updates.add('$key = ?');
          values.add(value);
        }
      });

      values.add(prospectId);

      if (updates.isEmpty) return;

      AppLogger.logRequest('UPDATE_PROSPECT',
          'UPDATE Prospect SET ${updates.join(", ")}', values);

      await _mysqlService.query(
        'UPDATE Prospect SET ${updates.join(", ")}, date_update = NOW() WHERE id_prospect = ?',
        values,
      );

      AppLogger.success('Prospect #$prospectId mis à jour');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la mise à jour du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la mise à jour: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteProspect(int prospectId) async {
    try {
      AppLogger.logRequest('DELETE_PROSPECT',
          'DELETE FROM Prospect WHERE id_prospect = ?', [prospectId]);

      await _mysqlService.query(
        'DELETE FROM Prospect WHERE id_prospect = ?',
        [prospectId],
      );
      await _mysqlService.query('DELETE FROM Prospect WHERE id = ?', [
        prospectId,
      ]);

      AppLogger.success('Prospect #$prospectId supprimé');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la suppression du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la suppression: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === INTERACTIONS ===

  Future<List<Interaction>> getInteractions(int prospectId) async {
    try {
      AppLogger.logRequest('INTERACTIONS',
          'SELECT * FROM Interaction WHERE id_prospect = ?', [prospectId]);

      final results = await _mysqlService.query(
        '''SELECT * FROM Interaction 
           WHERE id_prospect = ? 
           ORDER BY date_interaction DESC''',
        [prospectId],
      );

      AppLogger.logResponse('INTERACTIONS', results.length);

      return results
          .map(
            (row) => Interaction(
              id: (row['id_interaction'] as num).toInt(),
              idProspect: (row['id_prospect'] as num).toInt(),
              idCompte: (row['id_compte'] as num).toInt(),
              type: row['type'] as String,
              note: row['note'] as String,
              dateInteraction: DateTime.parse(
                row['date_interaction'].toString(),
              ),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des interactions', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la récupération: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createInteraction(
    int prospectId,
    int userId,
    String type,
    String note,
    DateTime dateInteraction,
  ) async {
    try {
      if (note.isEmpty) {
        throw ValidationException(
          message: 'La note est obligatoire',
          code: 'EMPTY_NOTE',
        );
      }

      AppLogger.logRequest('CREATE_INTERACTION', 'INSERT INTO Interaction', [
        prospectId,
        userId,
        type,
        note,
        dateInteraction,
      ]);

      await _mysqlService.query(
        '''INSERT INTO Interaction 
           (id_prospect, id_compte, type, note, date_interaction)
           VALUES (?, ?, ?, ?, ?)''',
        [prospectId, userId, type, note, dateInteraction],
      );

      AppLogger.success('Interaction créée pour le prospect #$prospectId');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de l\'interaction', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === STATISTIQUES ===

  Future<List<ProspectStats>> getProspectStats(int userId) async {
    try {
      AppLogger.logRequest(
          'STATS',
          'SELECT status, COUNT(*) FROM Prospect WHERE assignation = ?',
          [userId]);

      final results = await _mysqlService.query(
        '''SELECT status, COUNT(*) as count 
           FROM Prospect 
           WHERE assignation = ? 
           GROUP BY status''',
        [userId],
      );

      AppLogger.logResponse('STATS', results.length);

      return results
          .map(
            (row) => ProspectStats(
              status: row['status'] as String,
              count: (row['count'] as num).toInt(),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ConversionStats> getConversionStats(int userId) async {
    try {
      AppLogger.logRequest('CONVERSION_STATS',
          'SELECT COUNT(*), SUM(...) FROM Prospect', [userId]);

      final results = await _mysqlService.query(
        '''SELECT 
             COUNT(*) as total,
             SUM(CASE WHEN status = 'converti' THEN 1 ELSE 0 END) as converted
           FROM Prospect 
           WHERE assignation = ?''',
        [userId],
      );

      final row = results.first;
      final total = (row['total'] as num).toInt();
      final converted = (row['converted'] as num?)?.toInt() ?? 0;
      final rate = total > 0 ? converted / total : 0.0;

      AppLogger.success('Conversion rate: ${(rate * 100).toStringAsFixed(2)}%');

      return ConversionStats(
        totalProspects: total,
        convertedClients: converted,
        conversionRate: rate,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la récupération des stats de conversion',
          e, stackTrace);
      throw DatabaseException(
        message: 'Erreur: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }
}
