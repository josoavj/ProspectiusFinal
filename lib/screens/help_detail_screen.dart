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
        _buildHeader(Icons.auto_stories_outlined, 'Démarrer avec Prospectius', colorScheme),
        const SizedBox(height: 24),
        _buildStep(
          '1',
          'Ajout assisté (Wizard)',
          'Utilisez l\'assistant en 5 étapes pour créer un prospect complet. Tout nouveau prospect commence avec le statut "Intéressé".',
          colorScheme,
        ),
        _buildStep(
          '2',
          'Gestion multi-numéros',
          'Vous pouvez enregistrer jusqu\'à 3 numéros de téléphone par contact. Le formatage malgache est appliqué automatiquement (+261).',
          colorScheme,
        ),
        _buildStep(
          '3',
          'Pipeline Kanban',
          'Déplacez vos fiches entre les colonnes "Intéressé", "Négociation", "Converti" ou "Perdu" pour suivre vos ventes visuellement.',
          colorScheme,
        ),
        _buildStep(
          '4',
          'Protection RGPD',
          'N\'oubliez pas de renseigner la source du consentement à l\'étape 3 de l\'ajout pour être en conformité avec la loi sur les données.',
          colorScheme,
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Automatisme',
          'Dès que vous ajoutez une interaction initiale lors de la création, le prospect est prêt pour votre suivi dans le Pipeline.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildKeyboardShortcuts(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.keyboard_alt_outlined, 'Raccourcis de productivité', colorScheme),
        const SizedBox(height: 24),
        const Text(
          'Maîtrisez Prospectius du bout des doigts grâce aux combinaisons de touches système.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildShortcutRow('Ctrl + N', 'Nouveau Prospect', 'Ouvre instantanément l\'assistant d\'ajout en 5 étapes.', colorScheme),
        _buildShortcutRow('Ctrl + F', 'Recherche Globale', 'Active le moteur d\'exploration pour filtrer vos contacts.', colorScheme),
        _buildShortcutRow('Échap', 'Fermer / Annuler', 'Quitte une fenêtre surgissante ou l\'assistant en cours sans enregistrer.', colorScheme),
        _buildShortcutRow('F5', 'Actualisation', 'Force la synchronisation des données avec votre base MySQL.', colorScheme),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Astuce expert',
          'Utilisez Ctrl+N depuis n\'importe quel écran pour saisir une opportunité sans interrompre votre navigation actuelle.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.verified_user_outlined, 'Sécurité de niveau militaire', colorScheme),
        const SizedBox(height: 24),
        _buildSectionTitle('Souveraineté des données'),
        _buildParagraph('Vos prospects restent CHEZ VOUS. L\'application communique directement avec votre serveur MySQL local. Aucune donnée ne transite par un cloud tiers.'),
        const SizedBox(height: 24),
        _buildSectionTitle('Chiffrement BCrypt'),
        _buildParagraph('Les mots de passe des utilisateurs sont hachés avec l\'algorithme BCrypt, garantissant une protection maximale contre les tentatives d\'intrusion.'),
        const SizedBox(height: 24),
        _buildSectionTitle('Stratégie de Sauvegarde'),
        _buildParagraph('Deux options s\'offrent à vous dans les paramètres : la sauvegarde Standard (automatique) et la sauvegarde Personnalisée (pour clé USB ou disque externe).'),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Intégrité',
          'Le système de verrouillage optimiste empêche toute perte de données si deux collègues modifient le même contact simultanément.',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSupportInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(Icons.alternate_email_outlined, 'Assistance APEXNova Labs', colorScheme),
        const SizedBox(height: 24),
        const Text(
          'Notre équipe technique est à votre disposition pour garantir la pérennité de votre installation.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildContactItem(
          Icons.bug_report_outlined,
          'Support Technique',
          'Signaler un bug ou une erreur de connexion SQL via notre dépôt GitHub.',
          () => _launchURL('https://github.com/josoavj/ProspectiusFinal/issues'),
          colorScheme,
        ),
        _buildContactItem(
          Icons.email_outlined,
          'Contact Partenariat',
          'Pour des besoins de personnalisation avancée : josoavonjiniaina13@gmail.com',
          () => _launchURL('mailto:josoavonjiniaina13@gmail.com'),
          colorScheme,
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          'Disponibilité',
          'L\'assistance est assurée du lundi au vendredi. Nous répondons généralement sous 24 à 48 heures.',
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
