import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_logger.dart';
import '../utils/exception_handler.dart';
import '../utils/validators.dart';

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

  Widget _buildAvatarSection(dynamic user, ColorScheme colorScheme) {
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

  Widget _buildProfileCard(dynamic user, ColorScheme colorScheme) {
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
          Expanded(child: OutlinedButton(onPressed: _isLoading ? null : () { _initializeControllers(); setState(() => _isEditing = false); }, child: const Text('Annuler'))),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveChanges, 
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary), 
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enregistrer')
            )
          ),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06CE70), foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Modifier le mot de passe'),
            style: OutlinedButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => _PasswordChangeDialog(
        passwordController: passwordController,
        confirmController: confirmController,
      ),
    );
  }
}

class _PasswordChangeDialog extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const _PasswordChangeDialog({
    required this.passwordController,
    required this.confirmController,
  });

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  bool _obscure = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _showCriteria = false;
  bool _passwordsMatch = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_updateCriteria);
    widget.confirmController.addListener(_updateCriteria);
  }

  void _updateCriteria() {
    final password = widget.passwordController.text;
    final confirm = widget.confirmController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _passwordsMatch = password.isNotEmpty && password == confirm;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Modifier le mot de passe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                ),
              ),
            ],
            Focus(
              onFocusChange: (hasFocus) => setState(() => _showCriteria = hasFocus),
              child: TextField(
                controller: widget.passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showCriteria ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildLiveCriteria(colorScheme),
              ) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.confirmController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            _buildMatchIndicator(colorScheme),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final password = widget.passwordController.text;
            final confirm = widget.confirmController.text;

            final validation = Validators.validatePassword(password);
            if (!validation.isValid) {
              setState(() => _error = validation.error);
              return;
            }

            if (password != confirm) {
              setState(() => _error = 'Les mots de passe ne correspondent pas');
              return;
            }

            final auth = context.read<AuthProvider>();
            final success = await auth.changePassword(auth.currentUser!.id, password);
            if (success && context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour')));
            } else if (context.mounted) {
              setState(() => _error = auth.error ?? 'Erreur lors du changement');
            }
          },
          child: const Text('Mettre à jour'),
        ),
      ],
    );
  }

  Widget _buildLiveCriteria(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCriteriaItem('8 caractères minimum', _hasMinLength, colorScheme),
          _buildCriteriaItem('Une majuscule (A-Z)', _hasUppercase, colorScheme),
          _buildCriteriaItem('Une minuscule (a-z)', _hasLowercase, colorScheme),
          _buildCriteriaItem('Un chiffre (0-9)', _hasDigits, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMatchIndicator(ColorScheme colorScheme) {
    if (widget.confirmController.text.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(
            _passwordsMatch ? Icons.check_circle_outline : Icons.error_outline,
            size: 14,
            color: _passwordsMatch ? const Color(0xFF06CE70) : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            _passwordsMatch ? 'Les mots de passe correspondent' : 'Les mots de passe sont différents',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _passwordsMatch ? const Color(0xFF06CE70) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String label, bool isMet, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: isMet ? const Color(0xFF06CE70) : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
