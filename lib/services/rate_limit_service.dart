import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class RateLimitService {
  static final RateLimitService _instance = RateLimitService._internal();
  static const int maxAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  factory RateLimitService() {
    return _instance;
  }

  RateLimitService._internal();

  /// Enregistre une tentative de connexion échouée
  Future<void> recordFailedAttempt(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$username';
      final lockoutKey = 'login_lockout_$username';

      // Vérifier si le compte est verrouillé
      final lockoutTime = prefs.getInt(lockoutKey);
      if (lockoutTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now < lockoutTime) {
          final minutesLeft = ((lockoutTime - now) / 60000).ceil();
          AppLogger.warning(
            'Compte "$username" verrouillé, $minutesLeft min restantes',
          );
          throw RateLimitException(
            message:
                'Compte temporairement verrouillé après trop de tentatives',
            code: 'ACCOUNT_LOCKED',
            retryAfterSeconds: (lockoutTime - now) ~/ 1000,
          );
        }
      }

      // Récupérer les tentatives actuelles
      final attemptData = prefs.getString(key);
      List<int> attempts = [];

      if (attemptData != null) {
        try {
          attempts = (attemptData.split(',')).map((t) => int.parse(t)).toList();
        } catch (e) {
          AppLogger.warning('Erreur parsing tentatives: $e');
        }
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final tenMinutesAgo = now - (10 * 60 * 1000);

      // Supprimer les tentatives de plus de 10 minutes
      attempts.removeWhere((t) => t < tenMinutesAgo);

      // Ajouter la nouvelle tentative
      attempts.add(now);

      // Sauvegarder
      await prefs.setString(key, attempts.join(','));

      AppLogger.warning(
        'Tentative échouée pour "$username" (${attempts.length}/$maxAttempts)',
      );

      // Vérifier si limite atteinte
      if (attempts.length >= maxAttempts) {
        // Verrouiller le compte
        final lockoutUntil = now + (lockoutDurationMinutes * 60 * 1000);
        await prefs.setInt(lockoutKey, lockoutUntil);

        AppLogger.error(
          'ALERTE SÉCURITÉ: Compte "$username" verrouillé après $maxAttempts tentatives échouées',
        );

        throw RateLimitException(
          message:
              'Trop de tentatives de connexion. Compte verrouillé $lockoutDurationMinutes minutes',
          code: 'TOO_MANY_ATTEMPTS',
          retryAfterSeconds: lockoutDurationMinutes * 60,
        );
      }
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      AppLogger.error('Erreur rate limiting', e);
    }
  }

  /// Réinitialise les tentatives après une connexion réussie
  Future<void> recordSuccessfulLogin(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$username';
      final lockoutKey = 'login_lockout_$username';

      await prefs.remove(key);
      await prefs.remove(lockoutKey);

      AppLogger.info('Tentatives de connexion réinitialisées pour "$username"');
    } catch (e) {
      AppLogger.error('Erreur lors de la réinitialisation des tentatives', e);
    }
  }

  /// Vérifier si un compte est verrouillé
  Future<bool> isAccountLocked(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutKey = 'login_lockout_$username';
      final lockoutTime = prefs.getInt(lockoutKey);

      if (lockoutTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now < lockoutTime) {
          return true;
        } else {
          // Déverrouiller si le temps est écoulé
          await prefs.remove(lockoutKey);
        }
      }
      return false;
    } catch (e) {
      AppLogger.error('Erreur vérification verrouillage', e);
      return false;
    }
  }

  /// Obtenir le nombre de tentatives restantes
  Future<int> getRemainingAttempts(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$username';
      final attemptData = prefs.getString(key);

      if (attemptData == null) {
        return maxAttempts;
      }

      try {
        final attempts =
            (attemptData.split(',')).map((t) => int.parse(t)).toList();
        final now = DateTime.now().millisecondsSinceEpoch;
        final tenMinutesAgo = now - (10 * 60 * 1000);

        final validAttempts = attempts.where((t) => t >= tenMinutesAgo).length;
        return (maxAttempts - validAttempts).clamp(0, maxAttempts);
      } catch (e) {
        return maxAttempts;
      }
    } catch (e) {
      AppLogger.error('Erreur obtention tentatives restantes', e);
      return maxAttempts;
    }
  }

  /// Obtenir le temps avant déverrouillage (en secondes)
  Future<int?> getLockoutTimeRemaining(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutKey = 'login_lockout_$username';
      final lockoutTime = prefs.getInt(lockoutKey);

      if (lockoutTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now < lockoutTime) {
          return ((lockoutTime - now) / 1000).ceil();
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Erreur obtention temps verrouillage', e);
      return null;
    }
  }

  /// Débloquer manuellement un compte (admin)
  Future<void> unlockAccount(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutKey = 'login_lockout_$username';
      final key = 'login_attempts_$username';

      await prefs.remove(lockoutKey);
      await prefs.remove(key);

      AppLogger.info('Compte "$username" déverrouillé manuellement');
    } catch (e) {
      AppLogger.error('Erreur déblocage compte', e);
    }
  }
}

/// Exception levée lors d'un dépassement de rate limit
class RateLimitException implements Exception {
  final String message;
  final String code;
  final int retryAfterSeconds;

  RateLimitException({
    required this.message,
    required this.code,
    required this.retryAfterSeconds,
  });

  @override
  String toString() => message;
}
