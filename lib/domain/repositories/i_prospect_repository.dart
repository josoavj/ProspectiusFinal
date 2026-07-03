import '../../models/prospect.dart';
import '../../models/interaction.dart';
import '../../models/stats.dart';
import '../../models/status_history.dart';

abstract class IProspectRepository {
  Future<List<Prospect>> getProspects(int userId, String userRole, {int limit = 20, int offset = 0});
  Future<void> createProspect(Map<String, dynamic> data);
  Future<void> updateProspect(int id, Map<String, dynamic> data);
  Future<void> updateStatus(int id, String newStatus, int changedBy);
  Future<void> deleteProspect(int id);
  
  Future<List<Interaction>> getInteractions(int prospectId);
  Future<void> createInteraction(Map<String, dynamic> data);
  
  Future<List<StatusHistory>> getStatusHistory(int prospectId);
  
  Future<List<ProspectStats>> getStats(int userId, String userRole);
  Future<ConversionStats> getConversionStats(int userId, String userRole);
}
