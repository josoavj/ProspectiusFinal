import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget réutilisable pour afficher des données avec gestion des états
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
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.successBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.onRetry,
    this.emptyMessage = 'Aucune donnée',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder?.call() ?? const SkeletonListLoader();
    }

    if (error != null && error!.isNotEmpty) {
      return errorBuilder?.call(error!, onRetry ?? () {}) ??
          _buildDefaultError(context, error!);
    }

    if (data == null || data!.isEmpty) {
      return emptyBuilder?.call() ?? _buildDefaultEmpty(context);
    }

    return successBuilder(data!);
  }

  Widget _buildDefaultError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
            const SizedBox(height: 16),
            Text('Erreur', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red[600])),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(emptyMessage, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

/// Builder simplifié avec support Skeleton
class SimpleStateBuilder extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Widget child;
  final Widget? loadingWidget;

  const SimpleStateBuilder({
    super.key,
    required this.isLoading,
    required this.error,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const SkeletonListLoader();
    }

    if (error != null && error!.isNotEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 56, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Une erreur s\'est produite', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(error!, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

// --- SKELETON LOADERS ---

class SkeletonListLoader extends StatelessWidget {
  const SkeletonListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 14.0, color: Colors.white),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                    Container(width: 150.0, height: 10.0, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonKanbanLoader extends StatelessWidget {
  const SkeletonKanbanLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: Row(
        children: List.generate(3, (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ),
    );
  }
}
