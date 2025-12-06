import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// Service pour gérer les erreurs et timeouts de manière robuste
/// Prévient les écrans bloqués sur le loading
class ErrorHandlingService {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);

  /// Exécute une fonction asynchrone avec timeout et gestion d'erreur
  /// Si le timeout est dépassé, on retourne une erreur au lieu de bloquer
  static Future<T> executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = defaultTimeout,
    String operationName = 'Opération',
    T? defaultValue,
  }) async {
    try {
      AppLogger.debug(
          'Démarrage: $operationName (timeout: ${timeout.inSeconds}s)');

      final result = await operation().timeout(
        timeout,
        onTimeout: () {
          final message =
              '$operationName a dépassé le timeout (${timeout.inSeconds}s)';
          AppLogger.error(message);
          throw TimeoutException(
            message: message,
            operationName: operationName,
            timeout: timeout,
          );
        },
      );

      AppLogger.success('$operationName terminée avec succès');
      return result;
    } on TimeoutException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de $operationName', e, stackTrace);
      rethrow;
    }
  }

  /// Enveloppe une opération pour ajouter des logs détaillés
  static Future<T> executeWithLogging<T>(
    Future<T> Function() operation, {
    String operationName = 'Opération',
  }) async {
    try {
      AppLogger.debug('Démarrage: $operationName');
      final result = await operation();
      AppLogger.success('$operationName: SUCCÈS');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('$operationName: ERREUR - $e', null, stackTrace);
      rethrow;
    }
  }

  /// Reconstruit l'écran avec un message d'erreur au lieu de rester sur le loading
  static Future<void> handleProviderError(
    BuildContext context,
    String error, {
    String title = 'Erreur',
    VoidCallback? onRetry,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(error),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onRetry();
                },
                child: const Text('Réessayer'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Exception levée quand une opération dépasse le timeout
class TimeoutException implements Exception {
  final String message;
  final String operationName;
  final Duration timeout;

  TimeoutException({
    required this.message,
    required this.operationName,
    required this.timeout,
  });

  @override
  String toString() => message;
}

/// Widget pour afficher les erreurs de manière gracieuse
class ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String title;

  const ErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title = 'Une erreur s\'est produite',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[600],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher un état de chargement avec timeout protection
class SafeLoadingWidget extends StatefulWidget {
  final Duration timeout;
  final String message;

  const SafeLoadingWidget({
    super.key,
    this.timeout = const Duration(seconds: 30),
    this.message = 'Chargement en cours...',
  });

  @override
  State<SafeLoadingWidget> createState() => _SafeLoadingWidgetState();
}

class _SafeLoadingWidgetState extends State<SafeLoadingWidget> {
  bool _isTimeoutExceeded = false;

  @override
  void initState() {
    super.initState();

    // Vérifier le timeout toutes les secondes
    Future.delayed(widget.timeout, () {
      if (mounted) {
        setState(() {
          _isTimeoutExceeded = true;
        });
        AppLogger.error(
            'LoadingWidget: Timeout dépassé après ${widget.timeout.inSeconds}s');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isTimeoutExceeded) {
      return ErrorWidget(
        error:
            'Le chargement a pris trop de temps (${widget.timeout.inSeconds}s).\nVérifiez votre connexion à la base de données.',
        title: 'Timeout du chargement',
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(widget.message),
          const SizedBox(height: 24),
          Text(
            'Si le chargement prend trop longtemps (> ${widget.timeout.inSeconds}s),\nveuillez redémarrer l\'application.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
