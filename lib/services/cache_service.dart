import '../models/prospect.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache en mémoire
  final Map<int, List<Prospect>> _prospectsCache = {};
  final Map<int, DateTime> _lastUpdate = {};
  
  // Durée de validité du cache (ex: 5 minutes)
  final Duration _cacheDuration = const Duration(minutes: 5);

  void setProspects(int userId, List<Prospect> prospects) {
    _prospectsCache[userId] = prospects;
    _lastUpdate[userId] = DateTime.now();
  }

  List<Prospect>? getProspects(int userId) {
    if (!_prospectsCache.containsKey(userId)) return null;
    
    final lastUpdate = _lastUpdate[userId];
    if (lastUpdate == null || DateTime.now().difference(lastUpdate) > _cacheDuration) {
      _prospectsCache.remove(userId);
      return null;
    }
    return _prospectsCache[userId];
  }

  void invalidate(int userId) {
    _prospectsCache.remove(userId);
    _lastUpdate.remove(userId);
  }

  void clearAll() {
    _prospectsCache.clear();
    _lastUpdate.clear();
  }
}
