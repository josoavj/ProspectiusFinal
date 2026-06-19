import '../../domain/repositories/i_prospect_repository.dart';
import '../../models/prospect.dart';
import '../../models/interaction.dart';
import '../../models/stats.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';

class ProspectRepositoryImpl implements IProspectRepository {
  final MySQLService _mysqlService;

  ProspectRepositoryImpl(this._mysqlService);

  @override
  Future<List<Prospect>> getProspects(int userId, {int limit = 20, int offset = 0}) async {
    final results = await _mysqlService.query(
      SqlQueries.selectProspectsByUserId,
      [userId, limit, offset],
    );

    return results.map((row) => Prospect(
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
    )).toList();
  }

  @override
  Future<void> createProspect(Map<String, dynamic> data) async {
    await _mysqlService.query(
      SqlQueries.insertProspect,
      [
        data['nom'],
        data['prenom'],
        data['email'],
        data['telephone'],
        data['adresse'],
        data['type'],
        data['userId'],
      ],
    );
  }

  @override
  Future<void> updateProspect(int id, Map<String, dynamic> data) async {
    // Liste blanche des colonnes autorisées pour éviter l'injection de colonnes
    const allowedColumns = {
      'nomp',
      'prenomp',
      'email',
      'telephone',
      'adresse',
      'type',
      'status',
      'assignation'
    };

    final updates = <String>[];
    final values = <dynamic>[];

    data.forEach((key, value) {
      if (allowedColumns.contains(key)) {
        updates.add('$key = ?');
        values.add(value);
      }
    });

    if (updates.isEmpty) return;

    values.add(id);

    await _mysqlService.query(
      'UPDATE Prospect SET ${updates.join(", ")}, date_update = NOW() WHERE id_prospect = ? AND deleted_at IS NULL',
      values,
    );
  }

  @override
  Future<void> deleteProspect(int id) async {
    await _mysqlService.query(SqlQueries.softDeleteProspect, [id]);
  }

  @override
  Future<List<Interaction>> getInteractions(int prospectId) async {
    final results = await _mysqlService.query(
      SqlQueries.selectInteractionsByProspectId,
      [prospectId],
    );

    return results.map((row) => Interaction(
      id: (row['id_interaction'] as num).toInt(),
      idProspect: (row['id_prospect'] as num).toInt(),
      idCompte: (row['id_compte'] as num).toInt(),
      type: row['type'] as String,
      note: row['note']?.toString() ?? '',
      dateInteraction: DateTime.parse(row['date_interaction'].toString()),
    )).toList();
  }

  @override
  Future<void> createInteraction(Map<String, dynamic> data) async {
    await _mysqlService.query(
      SqlQueries.insertInteraction,
      [
        data['prospectId'],
        data['userId'],
        data['type'],
        data['note'],
        data['dateInteraction'],
      ],
    );
  }

  @override
  Future<List<ProspectStats>> getStats(int userId) async {
    final results = await _mysqlService.query(
      SqlQueries.prospectStatsByStatus,
      [userId],
    );

    return results.map((row) => ProspectStats(
      status: row['status'] as String,
      count: (row['count'] as num).toInt(),
    )).toList();
  }

  @override
  Future<ConversionStats> getConversionStats(int userId) async {
    final results = await _mysqlService.query(
      SqlQueries.conversionStats,
      [userId],
    );

    final row = results.first;
    final total = (row['total'] as num).toInt();
    final converted = (row['converted'] as num?)?.toInt() ?? 0;
    final rate = total > 0 ? converted / total : 0.0;

    return ConversionStats(
      totalProspects: total,
      convertedClients: converted,
      conversionRate: rate,
    );
  }
}
