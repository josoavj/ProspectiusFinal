/// Exception générale pour les opérations de l'application
class AppException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception pour les erreurs d'authentification
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'AUTH_ERROR',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception pour les erreurs de base de données
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'DATABASE_ERROR',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception pour les erreurs de connexion
class ConnectionException extends AppException {
  ConnectionException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'CONNECTION_ERROR',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception pour les erreurs de validation
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception pour les ressources non trouvées
class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'NOT_FOUND',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Classe helper pour gérer les erreurs et les convertir en messages utilisateur
class ExceptionHandler {
  static String getErrorMessage(Exception e) {
    if (e is AppException) {
      return e.message;
    }

    if (e is FormatException) {
      return 'Erreur de format: ${e.message}';
    }

    return 'Une erreur est survenue: ${e.toString()}';
  }

  static String getErrorCode(Exception e) {
    if (e is AppException) {
      return e.code ?? 'UNKNOWN_ERROR';
    }
    return 'UNKNOWN_ERROR';
  }

  static bool isConnectionError(Exception e) {
    if (e is ConnectionException) return true;
    final message = e.toString().toLowerCase();
    return message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('network');
  }

  static bool isAuthError(Exception e) {
    return e is AuthException;
  }

  static bool isValidationError(Exception e) {
    return e is ValidationException;
  }

  static bool isNotFound(Exception e) {
    return e is NotFoundException;
  }
}
