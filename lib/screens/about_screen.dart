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
        child: Column(
          children: [
            _buildModernHeader(colorScheme),
            const SizedBox(height: 70), // Espace pour l'avatar qui dépasse
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildVisionSection(theme, colorScheme),
                    const SizedBox(height: 32),
                    _buildBenefitsSection(theme, colorScheme),
                    const SizedBox(height: 32),
                    _buildOrganizationSection(theme, colorScheme),
                    const SizedBox(height: 32),
                    _buildTeamSection(theme, colorScheme),
                    const SizedBox(height: 48),
                    _buildFooter(theme, colorScheme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180, // Ajusté pour correspondre au Profil
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
          ),
        ),
        Positioned(
          top: 25, // Même espace que sur le Profil
          child: Column(
            children: [
              const Text(
                'Prospectius',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROPULSEZ VOTRE CROISSANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -45, // Ajusté pour correspondre au Profil
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/images/Logo Prospectius.png',
                height: 110,
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisionSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'Notre Vision',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Prospectius est né d\'une idée simple : rendre la gestion commerciale accessible, humaine et ultra-performante. Nous croyons que chaque interaction compte et que la technologie doit être au service de vos relations, pas un obstacle.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Version v1.2.0 stable',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('L\'impact Prospectius', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        _buildBenefitCard(
          icon: Icons.auto_graph_outlined,
          title: 'Zéro oubli, 100% de suivi',
          desc: 'Centralisez vos contacts et ne laissez plus aucune opportunité s\'échapper.',
          color: Colors.blue,
        ),
        _buildBenefitCard(
          icon: Icons.shield_outlined,
          title: 'Souveraineté des données',
          desc: 'Vos données restent chez vous, sur votre serveur MySQL. Pas de cloud opaque.',
          color: Colors.green,
        ),
        _buildBenefitCard(
          icon: Icons.bolt_outlined,
          title: 'Efficacité native',
          desc: 'Une interface fluide optimisée pour Windows et Linux avec raccourcis clavier.',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({required IconData icon, required String title, required String desc, required Color color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('Géré par', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        InkWell(
          onTap: () => _launchURL('https://github.com/APEXNovaLabs'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                _buildAvatarWithFallback(
                  url: 'https://github.com/APEXNovaLabs.png',
                  fallbackIcon: Icons.business,
                  radius: 32,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'APEXNova Labs',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Équipe de développement spécialisée dans les solutions logicielles et mobiles',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, size: 20, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('L\'Équipe Core', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        _buildAuthorChip(
          name: 'Josoa VONJINIAINA',
          role: 'FullStack Developer',
          desc: 'Expert en architecture Backend, passionné par l\'UI/UX et les performances système.',
          avatarUrl: 'https://github.com/josoavj.png',
          url: 'https://github.com/josoavj',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _buildAuthorChip(
          name: 'Maminirina ANDRIAMASINORO',
          role: 'FullStack Developer',
          desc: 'Spécialiste en intégration fluide des processus métiers avec le backend.',
          avatarUrl: 'https://github.com/AinaMaminirina18.png',
          url: 'https://github.com/AinaMaminirina18',
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildAuthorChip({
    required String name,
    required String role,
    required String desc,
    required String avatarUrl,
    required String url,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            _buildAvatarWithFallback(
              url: avatarUrl,
              fallbackIcon: Icons.person,
              radius: 32,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    role,
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            Icon(Icons.link, size: 20, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithFallback({
    required String url,
    required IconData fallbackIcon,
    required double radius,
    required ColorScheme colorScheme,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: colorScheme.primary, size: radius),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.language, 'Web', () {}, colorScheme),
            _buildSocialIcon(Icons.code_rounded, 'GitHub', () => _launchURL('https://github.com/josoavj/ProspectiusFinal'), colorScheme),
            _buildSocialIcon(Icons.email_outlined, 'Support', () => _launchURL('mailto:josoavonjiniaina13@gmail.com'), colorScheme),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '© 2025 APEXNova Labs. Tous droits réservés.',
          style: TextStyle(color: colorScheme.outline, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          'Fièrement propulsé par Flutter & MariaDB',
          style: TextStyle(color: colorScheme.outline, fontSize: 11, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
