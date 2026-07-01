import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/app_logger.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isWindows) {
        await Process.run('start', [url], runInShell: true);
      }
    } catch (e) {
      AppLogger.error('Erreur ouverture URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Prospectius',
                  style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Application CRM - Gestion de Prospects',
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Version
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
                const SizedBox(height: 48),

                // Organization Card
                _buildSectionCard(
                  context,
                  title: 'Géré par',
                  child: _buildOrganizationCard(
                    context,
                    name: 'APEXNova Labs',
                    description: 'Developer team operating on software and mobile application development',
                    avatarUrl: 'https://avatars.githubusercontent.com/u/153268131?v=4',
                    organizationUrl: 'https://github.com/APEXNovaLabs',
                  ),
                ),
                const SizedBox(height: 24),

                // Features Card
                _buildSectionCard(
                  context,
                  title: 'Fonctionnalités Clés',
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        icon: Icons.assignment_ind_outlined,
                        title: 'Gestion Centralisée',
                        description: 'Regroupez toutes les données de vos prospects (coordonnées, entreprise, réseaux) dans un espace unique.',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.view_kanban_outlined,
                        title: 'Pipeline de Vente',
                        description: 'Visualisez et gérez votre tunnel de vente par simple glisser-déposer grâce à la vue Kanban intuitive.',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.forum_outlined,
                        title: 'Suivi des Échanges',
                        description: 'Historisez chaque interaction, assignez des responsables et planifiez vos prochaines actions de suivi.',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.notification_add_outlined,
                        title: 'Gestion des Rappels',
                        description: 'Ne manquez aucune relance. Créez des tâches et rappels personnalisés directement liés à vos fiches.',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Analyses & Statistiques',
                        description: 'Suivez vos taux de conversion et la performance de votre prospection en temps réel.',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.sync_lock_outlined,
                        title: 'Synchronisation MySQL',
                        description: 'Assurez la sécurité et la pérennité de vos données grâce à une synchronisation base de données robuste.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Developers Card
                _buildSectionCard(
                  context,
                  title: 'Développé par',
                  child: Column(
                    children: [
                      _buildDeveloperCard(
                        context,
                        name: 'Josoa VONJINIAINA',
                        role: 'Développeur Principal',
                        avatarUrl: 'https://avatars.githubusercontent.com/u/josoavj?v=4',
                        profileUrl: 'https://github.com/josoavj',
                      ),
                      const SizedBox(height: 12),
                      _buildDeveloperCard(
                        context,
                        name: 'Maminirina ANDRIAMASINORO',
                        role: 'Développeur Frontend',
                        avatarUrl: 'https://avatars.githubusercontent.com/u/AinaMaminirina18?v=4',
                        profileUrl: 'https://github.com/AinaMaminirina18',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Footer
                Text(
                  'Tous droits réservés © 2025 - APEXNova Labs',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Made with Flutter & MySQL',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, {required IconData icon, required String title, required String description}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(
    BuildContext context, {
    required String name,
    required String description,
    required String avatarUrl,
    required String organizationUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            onBackgroundImageError: (_, __) => AppLogger.warning('Erreur chargement avatar'),
            child: avatarUrl.isEmpty ? Icon(Icons.business, color: colorScheme.onPrimaryContainer) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _launchURL(organizationUrl),
            icon: Icon(Icons.open_in_new, size: 20, color: colorScheme.primary),
            tooltip: 'GitHub',
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    String? avatarUrl,
    String? profileUrl,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.secondaryContainer,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
            onBackgroundImageError: (_, __) => AppLogger.warning('Erreur chargement avatar'),
            child: (avatarUrl == null || avatarUrl.isEmpty) ? Icon(Icons.person, color: colorScheme.onSecondaryContainer) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(role, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          if (profileUrl != null)
            IconButton(
              onPressed: () => _launchURL(profileUrl),
              icon: Icon(Icons.link, size: 20, color: colorScheme.primary),
              tooltip: 'Voir le profil',
            ),
        ],
      ),
    );
  }
}
