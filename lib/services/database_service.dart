import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'mysql_service.dart';
import '../models/account.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../models/stats.dart';

class DatabaseService {
  final MySQLService _mysqlService = MySQLService();

  // === AUTHENTIFICATION ===

  Future<Map<String, dynamic>> authenticate(
    String username,
    String password,
  ) async {
    try {
      final results = await _mysqlService.query(
        'SELECT * FROM Account WHERE username = ?',
        [username],
      );

      if (results.isEmpty) {
        return {'success': false, 'message': 'Utilisateur non trouvé'};
      }

      final row = results.first;
      final hashedPassword = row['password'] as String;
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      // Simple hash comparison - À améliorer avec bcrypt si possible
      if (hashedPassword != passwordHash &&
          !_verifyPassword(password, hashedPassword)) {
        return {'success': false, 'message': 'Mot de passe incorrect'};
      }

      return {
        'success': true,
        'user': Account(
          id: row['id'] as int,
          nom: row['nom'] as String,
          prenom: row['prenom'] as String,
          email: row['email'] as String,
          username: row['username'] as String,
          typeCompte: row['type_compte'] as String,
          dateCreation: DateTime.parse(row['date_creation'].toString()),
        ),
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> createAccount(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
  ) async {
    try {
      // Vérifier l'unicité du username
      final existingUser = await _mysqlService.query(
        'SELECT id FROM Account WHERE username = ?',
        [username],
      );

      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Cet identifiant existe déjà'};
      }

      // Hacher le mot de passe
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      // Insérer le nouvel utilisateur
      await _mysqlService.query(
        '''INSERT INTO Account (nom, prenom, email, username, password, type_compte, date_creation)
           VALUES (?, ?, ?, ?, ?, ?, NOW())''',
        [nom, prenom, email, username, passwordHash, 'Utilisateur'],
      );

      return {'success': true, 'message': 'Compte créé avec succès'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // === PROSPECTS ===

  Future<List<Prospect>> getProspects(int userId) async {
    try {
      final results = await _mysqlService.query(
        'SELECT * FROM Prospect WHERE id_utilisateur = ? ORDER BY date_creation DESC',
        [userId],
      );

      return results
          .map(
            (row) => Prospect(
              id: row['id'] as int,
              nom: row['nom'] as String,
              prenom: row['prenom'] as String,
              email: row['email'] as String,
              telephone: row['telephone'] as String? ?? '',
              entreprise: row['entreprise'] as String? ?? '',
              poste: row['poste'] as String? ?? '',
              statut: row['statut'] as String? ?? 'En cours',
              source: row['source'] as String? ?? '',
              notes: row['notes'] as String? ?? '',
              idUtilisateur: row['id_utilisateur'] as int,
              dateCreation: DateTime.parse(row['date_creation'].toString()),
              dateModification: row['date_modification'] != null
                  ? DateTime.parse(row['date_modification'].toString())
                  : null,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des prospects: $e');
    }
  }

  Future<bool> createProspect(
    int userId,
    String nom,
    String prenom,
    String email,
    String telephone,
    String entreprise,
    String poste,
    String statut,
    String source,
    String notes,
  ) async {
    try {
      await _mysqlService.query(
        '''INSERT INTO Prospect 
           (nom, prenom, email, telephone, entreprise, poste, statut, source, notes, id_utilisateur, date_creation)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())''',
        [
          nom,
          prenom,
          email,
          telephone,
          entreprise,
          poste,
          statut,
          source,
          notes,
          userId,
        ],
      );
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  Future<bool> updateProspect(int prospectId, Map<String, dynamic> data) async {
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

      if (updates.isEmpty) return true;

      await _mysqlService.query(
        'UPDATE Prospect SET ${updates.join(", ")}, date_modification = NOW() WHERE id = ?',
        values,
      );
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  Future<bool> deleteProspect(int prospectId) async {
    try {
      await _mysqlService.query(
        'DELETE FROM Interaction WHERE id_prospect = ?',
        [prospectId],
      );
      await _mysqlService.query('DELETE FROM Prospect WHERE id = ?', [
        prospectId,
      ]);
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // === INTERACTIONS ===

  Future<List<Interaction>> getInteractions(int prospectId) async {
    try {
      final results = await _mysqlService.query(
        '''SELECT * FROM Interaction 
           WHERE id_prospect = ? 
           ORDER BY date_interaction DESC''',
        [prospectId],
      );

      return results
          .map(
            (row) => Interaction(
              id: row['id'] as int,
              idProspect: row['id_prospect'] as int,
              idUtilisateur: row['id_utilisateur'] as int,
              typeInteraction: row['type_interaction'] as String,
              description: row['description'] as String,
              dateInteraction: DateTime.parse(
                row['date_interaction'].toString(),
              ),
              dateCreation: DateTime.parse(row['date_creation'].toString()),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  Future<bool> createInteraction(
    int prospectId,
    int userId,
    String typeInteraction,
    String description,
    DateTime dateInteraction,
  ) async {
    try {
      await _mysqlService.query(
        '''INSERT INTO Interaction 
           (id_prospect, id_utilisateur, type_interaction, description, date_interaction, date_creation)
           VALUES (?, ?, ?, ?, ?, NOW())''',
        [prospectId, userId, typeInteraction, description, dateInteraction],
      );
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  // === STATISTIQUES ===

  Future<List<ProspectStats>> getProspectStats(int userId) async {
    try {
      final results = await _mysqlService.query(
        '''SELECT statut, COUNT(*) as count 
           FROM Prospect 
           WHERE id_utilisateur = ? 
           GROUP BY statut''',
        [userId],
      );

      return results
          .map(
            (row) => ProspectStats(
              statut: row['statut'] as String,
              count: row['count'] as int,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<ConversionStats> getConversionStats(int userId) async {
    try {
      final results = await _mysqlService.query(
        '''SELECT 
             COUNT(*) as total,
             SUM(CASE WHEN statut = 'Converti' THEN 1 ELSE 0 END) as converted
           FROM Prospect 
           WHERE id_utilisateur = ?''',
        [userId],
      );

      final row = results.first;
      final total = row['total'] as int;
      final converted = row['converted'] as int? ?? 0;
      final rate = total > 0 ? converted / total : 0.0;

      return ConversionStats(
        totalProspects: total,
        convertedClients: converted,
        conversionRate: rate,
      );
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Helper pour vérifier le mot de passe
  bool _verifyPassword(String password, String hash) {
    // Implémentation simple - améliore selon tes besoins
    return sha256.convert(utf8.encode(password)).toString() == hash;
  }
}
