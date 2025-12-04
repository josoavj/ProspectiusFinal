import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher des données avec gestion des états
/// Gère: loading, erreur, aucune donnée, succès
class DataStateWidget<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<T>? data;
  final Widget Function(List<T> data) successBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function(String error, VoidCallback onRetry)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const DataStateWidget({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.successBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.onRetry,
    this.emptyMessage = 'Aucune donnée',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // État de chargement
    if (isLoading) {
      return loadingBuilder?.call() ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    // État d'erreur
    if (error != null && error!.isNotEmpty) {
      return errorBuilder?.call(error!, onRetry ?? () {}) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.red[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
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

    // État aucune donnée
    if (data == null || data!.isEmpty) {
      return emptyBuilder?.call() ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
    }

    // État succès
    return successBuilder(data!);
  }
}

/// Builder plus simple pour juste afficher loading/erreur/data
class SimpleStateBuilder extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Widget child;
  final Duration timeout;

  const SimpleStateBuilder({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.child,
    this.timeout = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement en cours...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (error != null && error!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: Colors.orange[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Une erreur s\'est produite',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.orange[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
