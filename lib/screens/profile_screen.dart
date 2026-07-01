import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_logger.dart';
import '../utils/exception_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    _nomController = TextEditingController(text: user?.nom ?? '');
    _prenomController = TextEditingController(text: user?.prenom ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() async {
    setState(() { _isLoading = true; _successMessage = null; _errorMessage = null; });
    try {
      if (_nomController.text.isEmpty || _prenomController.text.isEmpty || _emailController.text.isEmpty) {
        throw ValidationException(message: 'Veuillez remplir tous les champs', code: 'INVALID_INPUT');
      }
      AppLogger.success('Profil mis à jour');
      setState(() { _successMessage = 'Profil mis à jour avec succès'; _isEditing = false; });
    } catch (e) {
      AppLogger.error('Erreur mise à jour profil', e);
      setState(() { _errorMessage = 'Erreur: $e'; });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) return const Center(child: Text('Utilisateur non connecté'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    _buildAvatarSection(user, colorScheme),
                    const SizedBox(height: 32),
                    if (_successMessage != null) _buildStatusMessage(_successMessage!, Colors.green),
                    if (_errorMessage != null) _buildStatusMessage(_errorMessage!, colorScheme.error),
                    const SizedBox(height: 16),
                    _buildProfileCard(user, colorScheme),
                    const SizedBox(height: 32),
                    _buildActionButtons(colorScheme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(user, ColorScheme colorScheme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(20)),
          child: Text(user.typeCompte, style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(message, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    );
  }

  Widget _buildProfileCard(user, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations Personnelles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _buildField('Nom', _nomController, _isEditing, colorScheme),
            _buildField('Prénom', _prenomController, _isEditing, colorScheme),
            _buildField('Email', _emailController, _isEditing, colorScheme, type: TextInputType.emailAddress),
            _buildReadOnlyField('Nom d\'utilisateur', user.username, colorScheme),
            _buildReadOnlyField('Membre depuis', '${user.dateCreation.day}/${user.dateCreation.month}/${user.dateCreation.year}', colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool enabled, ColorScheme colorScheme, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: type,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: !enabled,
              fillColor: enabled ? null : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(value, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () { _initializeControllers(); setState(() => _isEditing = false); }, child: const Text('Annuler'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: _handleSaveChanges, style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary), child: const Text('Enregistrer'))),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _isEditing = true),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Modifier le profil'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06CE70), foregroundColor: Colors.white),
      ),
    );
  }
}
