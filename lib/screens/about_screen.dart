import 'package:flutter/material.dart';
import 'dart:io';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    try {
      if (Platform.isLinux) {
        // Use xdg-open on Linux
        await Process.run('xdg-open', [url]);
      } else if (Platform.isMacOS) {
        // Use open on macOS
        await Process.run('open', [url]);
      } else if (Platform.isWindows) {
        // Use start on Windows
        await Process.run('start', [url], runInShell: true);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.people,
                      size: 60,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Prospectius',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Application CRM - Gestion de Prospects',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Version
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(height: 48),

                // Organization Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Géré par',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildOrganizationCard(
                            context,
                            name: 'APEXNova Labs',
                            description:
                                'Developer team operating on software and mobile application development',
                            avatarUrl:
                                'https://avatars.githubusercontent.com/u/153268131?v=4',
                            organizationUrl: 'https://github.com/APEXNovaLabs',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Description
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À propos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Prospectius est une application CRM moderne conçue pour faciliter la gestion efficace de vos prospects. '
                            'Elle vous permet de suivre, organiser et analyser vos prospects avec une interface intuitive et des outils puissants.\n\n'
                            'Avec Prospectius, vous pouvez:\n'
                            '• Gérer vos prospects et interactions\n'
                            '• Suivre le statut de chaque prospect\n'
                            '• Analyser vos statistiques de conversion\n'
                            '• Exporter vos données en Excel\n'
                            '• Synchroniser avec une base de données MySQL',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Developers
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Développé par',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildDeveloperCard(
                            context,
                            name: 'Josoa VONJINIAINA',
                            role: 'Développeur Principal',
                            avatarUrl:
                                'https://avatars.githubusercontent.com/u/josoavj?v=4',
                            profileUrl: 'https://github.com/josoavj',
                          ),
                          const SizedBox(height: 12),
                          _buildDeveloperCard(
                            context,
                            name: 'Collaborateurs',
                            role: 'Conception et Feedback',
                            profileUrl: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer
                Column(
                  children: [
                    Text(
                      'Tous droits réservés © 2025 - APEXNova Labs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Made with Flutter & MySQL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue[100],
            backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.business, size: 24, color: Colors.blue[600])
                : null,
          ),
          const SizedBox(width: 16),
          // Organization Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Button
          TextButton.icon(
            onPressed: () => _launchURL(organizationUrl),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('GitHub'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: avatarUrl != null ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: avatarUrl != null ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          if (avatarUrl != null && avatarUrl.isNotEmpty)
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue[100],
              backgroundImage: NetworkImage(avatarUrl),
              child: Icon(Icons.person, color: Colors.blue[600], size: 32),
            )
          else
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.people, color: Colors.grey[600], size: 32),
            ),
          const SizedBox(width: 16),
          // Developer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (profileUrl != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    child: TextButton.icon(
                      onPressed: () => _launchURL(profileUrl),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Voir le profil'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
