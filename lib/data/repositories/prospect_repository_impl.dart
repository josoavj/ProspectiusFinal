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

    final prospects = results.map((row) => Prospect.fromJson(row.fields)).toList();

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

    return results.map((row) => Interaction.fromJson(row.fields)).toList();
  }

  @override
  Future<void> createInteraction(Map<String, dynamic> data) async {
    // Utilisation d'une transaction pour garantir l'atomicité
    // (L'insertion de l'interaction et la mise à jour du statut)
    final connection = _mysqlService.getConnection();
    
    await connection.transaction((ctx) async {
      // 1. Insérer l'interaction
      await ctx.query(
        SqlQueries.insertInteraction,
        [
          data['prospectId'],
          data['userId'],
          data['idAssigne'],
          data['type'],
          data['note'],
          data['suivi'],
          (data['dateInteraction'] as DateTime).toUtc(),
        ],
      );

      // 2. Mise à jour automatique du statut du prospect si demandé ou nécessaire
      // Si c'est la première interaction ('nouveau'), on passe à 'interesse' par défaut
      // ou on utilise le statut spécifiquement passé dans data['newStatus']
      String? newStatus = data['newStatus'] as String?;
      
      if (newStatus != null) {
        await ctx.query(
          'UPDATE Prospect SET status = ?, date_update = NOW() WHERE id_prospect = ?',
          [newStatus, data['prospectId']],
        );
      } else {
        // Logique par défaut: nouveau -> interesse
        await ctx.query(
          'UPDATE Prospect SET status = "interesse", date_update = NOW() WHERE id_prospect = ? AND status = "nouveau"',
          [data['prospectId']],
        );
      }
    });

    _cache.clearAll();
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
