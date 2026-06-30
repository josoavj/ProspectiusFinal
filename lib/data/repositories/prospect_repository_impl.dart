import '../../domain/repositories/i_prospect_repository.dart';
import '../../models/prospect.dart';
import '../../models/interaction.dart';
import '../../models/stats.dart';
import '../../services/mysql_service.dart';
import '../../services/cache_service.dart';
import '../../core/constants/sql_queries.dart';

class ProspectRepositoryImpl implements IProspectRepository {
  final MySQLService _mysqlService;
  final CacheService _cache = CacheService();

  ProspectRepositoryImpl(this._mysqlService);

  @override
  Future<List<Prospect>> getProspects(int userId, {int limit = 20, int offset = 0}) async {
    // Tentative de récupération depuis le cache si on est sur la première page
    if (offset == 0) {
      final cached = _cache.getProspects(userId);
      if (cached != null) return cached;
    }

    final results = await _mysqlService.query(
      SqlQueries.selectProspectsByUserId,
      [userId, limit, offset],
    );

    final prospects = results.map((row) => Prospect(
      id: (row['id_prospect'] as num).toInt(),
      nom: row['nomp']?.toString() ?? '',
      prenom: row['prenomp']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      telephone: row['telephone']?.toString() ?? '',
      adresse: row['adresse']?.toString() ?? '',
      type: row['type']?.toString() ?? 'particulier',
      status: row['status']?.toString() ?? 'nouveau',
      priorite: row['priorite']?.toString() ?? 'moyenne',
      source: row['source']?.toString(),
      nomEntreprise: row['nom_entreprise']?.toString(),
      poste: row['poste']?.toString(),
      linkedinUrl: row['linkedin_url']?.toString(),
      siteWeb: row['site_web']?.toString(),
      description: row['description']?.toString(),
      creation: DateTime.parse(row['creation'].toString()),
      dateUpdate: DateTime.parse(row['date_update'].toString()),
      assignation: (row['assignation'] as num?)?.toInt() ?? 0,
    )).toList();

    // Mise en cache si c'est la première page
    if (offset == 0) {
      _cache.setProspects(userId, prospects);
    }

    return prospects;
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
        data['priorite'] ?? 'moyenne',
        data['source'],
        data['nomEntreprise'],
        data['poste'],
        data['linkedinUrl'],
        data['siteWeb'],
        data['description'],
      ],
    );
    _cache.invalidate(data['userId'] as int);
  }

  @override
  Future<void> updateProspect(int id, Map<String, dynamic> data) async {
    // Liste blanche des colonnes autorisées
    const allowedColumns = {
      'nomp',
      'prenomp',
      'email',
      'telephone',
      'adresse',
      'type',
      'status',
      'assignation',
      'priorite',
      'source',
      'nom_entreprise',
      'poste',
      'linkedin_url',
      'site_web',
      'description'
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
    
    // Invalider le cache (on pourrait être plus fin, mais c'est sûr)
    _cache.clearAll(); 
  }

  @override
  Future<void> deleteProspect(int id) async {
    await _mysqlService.query(SqlQueries.softDeleteProspect, [id]);
    _cache.clearAll();
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
        (data['dateInteraction'] as DateTime).toUtc(),
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
