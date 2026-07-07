import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/app_logger.dart';

class HelpDetailScreen extends StatelessWidget {
  final String title;
  final String type; // 'start', 'keyboard', 'security', 'support'

  const HelpDetailScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildContent(context, colorScheme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    switch (type) {
      case 'start':
        return _buildQuickStart(context, colorScheme);
      case 'keyboard':
        return _buildKeyboardShortcuts(context, colorScheme);
      case 'security':
        return _buildSecurityInfo(context, colorScheme);
      case 'support':
        return _buildSupportInfo(context, colorScheme);
      default:
        return const Center(child: Text('Contenu non disponible'));
    }
  }

  Widget _buildQuickStart(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.auto_stories_outlined, 'Bienvenue sur Prospectius', colorScheme),
        const SizedBox(height: 24),
        _buildStep(
          '1',
          'Ajoutez vos prospects',
          'Cliquez sur le bouton "+" en bas de votre liste. Renseignez le nom, l\'email et le type de relation (Particulier ou Entreprise).',
          colorScheme,
        ),
        _buildStep(
          '2',
          'Utilisez le Pipeline',
          'C\'est votre tableau de bord. Faites glisser une fiche d\'une colonne à l\'autre pour marquer l\'avancement de votre négociation.',
          colorScheme,
        ),
        _buildStep(
          '3',
          'Notez vos échanges',
          'Dans la fiche d\'un prospect, allez dans "Suivi". Ajoutez un résumé de vos appels ou rendez-vous pour ne rien oublier.',
          colorScheme,
        ),
        _buildStep(
          '4',
          'Planifiez des relances',
          'Utilisez l\'onglet "Tâches" pour programmer une action future. L\'application vous aidera à rester organisé.',
          colorScheme,
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Conseil d\'expert',
          'Plus vous renseignez de détails dans vos notes de suivi, plus vos futures ventes seront facilitées car vous connaîtrez parfaitement les besoins de votre contact.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildKeyboardShortcuts(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.keyboard_alt_outlined, 'Travailler plus vite', colorScheme),
        const SizedBox(height: 24),
        const Text(
          'Gagnez en efficacité sur Windows en utilisant ces combinaisons de touches simples.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildShortcutRow('Ctrl + F', 'Recherche / Exploration', 'Ouvre instantanément la barre de recherche globale.', colorScheme),
        _buildShortcutRow('Ctrl + N', 'Nouveau Prospect', 'Affiche le formulaire pour ajouter un nouveau contact.', colorScheme),
        _buildShortcutRow('Échap', 'Fermer', 'Ferme les fenêtres surgissantes ou annule l\'action en cours.', colorScheme),
        _buildShortcutRow('F5', 'Actualiser', 'Rafraîchit les données de la page actuelle (Prospects, Pipeline).', colorScheme),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Astuce',
          'Ces raccourcis sont conçus pour vous permettre de ne pas lâcher votre clavier lors de vos sessions de prospection intensive.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.verified_user_outlined, 'Vos données vous appartiennent', colorScheme),
        const SizedBox(height: 24),
        _buildSectionTitle('Souveraineté Totale'),
        _buildParagraph('Contrairement à d\'autres services, Prospectius ne stocke rien sur des serveurs distants ou dans le "Cloud". Toutes vos données sont hébergées sur VOTRE propre machine ou serveur via MySQL.'),
        const SizedBox(height: 20),
        _buildSectionTitle('Chiffrement des Accès'),
        _buildParagraph('Vos identifiants de connexion et vos mots de passe de base de données ne sont jamais écrits en clair sur votre disque dur. Ils sont protégés par le coffre-fort numérique de votre système d\'exploitation (Windows Keystore).'),
        const SizedBox(height: 20),
        _buildSectionTitle('Protection contre l\'Écrasement'),
        _buildParagraph('Grâce au "Verrouillage Optimiste", le système empêche que deux utilisateurs ne modifient le même prospect au même instant, évitant ainsi toute perte accidentelle d\'information.'),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Engagement Confidentialité',
          'Nous n\'avons aucun accès à vos listes de clients. Votre réussite commerciale reste votre secret le plus précieux.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSupportInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.alternate_email_outlined, 'Nous sommes à votre écoute', colorScheme),
        const SizedBox(height: 24),
        const Text(
          'Une difficulté technique ou une suggestion pour améliorer Prospectius ? Voici comment nous joindre.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildContactItem(
          Icons.bug_report_outlined,
          'Signaler un problème',
          'Utilisez notre plateforme GitHub pour nous transmettre vos captures d\'écran et descriptions.',
          () => _launchURL('https://github.com/josoavj/ProspectiusFinal/issues'),
          colorScheme,
        ),
        _buildContactItem(
          Icons.lightbulb_outline,
          'Suggérer une idée',
          'Nous adorons les bonnes idées pour rendre l\'application plus simple.',
          () => _launchURL('https://github.com/josoavj/ProspectiusFinal/discussions'),
          colorScheme,
        ),
        _buildContactItem(
          Icons.email_outlined,
          'Contact direct',
          'Pour toute autre demande : josoavonjiniaina13@gmail.com',
          () => _launchURL('mailto:josoavonjiniaina13@gmail.com'),
          colorScheme,
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Information',
          'L\'équipe APEXNova Labs s\'efforce de répondre à toutes les demandes sous un délai de 48 heures ouvrées.',
          colorScheme,
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(IconData icon, String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String desc, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String keys, String action, String desc, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String desc, VoidCallback onTap, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.open_in_new, size: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }

  Widget _buildInfoCard(String title, String content, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

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
}
