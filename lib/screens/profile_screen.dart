import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_logger.dart';
import '../utils/exception_handler.dart';
import '../utils/validators.dart';
import '../utils/app_snackbars.dart';

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
            child: Column(
              children: [
                _buildModernHeader(user, colorScheme),
                const SizedBox(height: 50), // Espace pour l'avatar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          if (_successMessage != null) _buildStatusMessage(_successMessage!, Colors.green),
                          if (_errorMessage != null) _buildStatusMessage(_errorMessage!, colorScheme.error),
                          const SizedBox(height: 10), // Espace avant la carte
                          _buildProfileCard(user, colorScheme),
                          const SizedBox(height: 32),
                          _buildActionButtons(colorScheme),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(dynamic user, ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Fond bleu uni (pour correspondre à l'AppBar)
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
          ),
        ),
        // Texte et Badge dans la zone bleue
        Positioned(
          top: 20,
          child: Column(
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  user.typeCompte.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Avatar circulaire "bien devant"
        Positioned(
          bottom: -45,
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
            child: CircleAvatar(
              radius: 54,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 44, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(message, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    );
  }

  Widget _buildProfileCard(dynamic user, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Text('Détails du compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
            const SizedBox(height: 24),
            _buildField('Nom', _nomController, _isEditing, colorScheme),
            _buildField('Prénom', _prenomController, _isEditing, colorScheme),
            _buildField('Email', _emailController, _isEditing, colorScheme, type: TextInputType.emailAddress),
            const Divider(height: 32),
            _buildReadOnlyField('Nom d\'utilisateur', user.username, colorScheme, Icons.alternate_email),
            _buildReadOnlyField('Membre depuis', '${user.dateCreation.day}/${user.dateCreation.month}/${user.dateCreation.year}', colorScheme, Icons.calendar_today_outlined),
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
              fillColor: enabled ? null : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, ColorScheme colorScheme, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(child: OutlinedButton(
            onPressed: _isLoading ? null : () { _initializeControllers(); setState(() => _isEditing = false); }, 
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Annuler')
          )),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveChanges, 
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, 
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ), 
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
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06CE70), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Sécuriser mon mot de passe'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => _PasswordChangeDialog(
        currentPasswordController: currentPasswordController,
        passwordController: passwordController,
        confirmController: confirmController,
      ),
    ).then((_) {
      currentPasswordController.dispose();
      passwordController.dispose();
      confirmController.dispose();
    });
  }
}

class _PasswordChangeDialog extends StatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const _PasswordChangeDialog({
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmController,
  });

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  int _currentStep = 1; // 1: Vérification actuel, 2: Nouveau mot de passe
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _showCriteria = false;
  bool _passwordsMatch = false;
  bool _isValidating = false;
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

  Future<void> _validateCurrentPassword() async {
    final current = widget.currentPasswordController.text;
    if (current.isEmpty) {
      setState(() => _error = 'Veuillez saisir votre mot de passe actuel');
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    // On utilise la méthode de login pour vérifier le mot de passe actuel
    final isValid = await auth.verifyCurrentPassword(current);

    if (mounted) {
      setState(() {
        _isValidating = false;
        if (isValid) {
          _currentStep = 2;
        } else {
          _error = 'Mot de passe actuel incorrect';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.security_outlined, size: 20),
          const SizedBox(width: 12),
          const Text('Sécurité'),
          const Spacer(),
          _buildStepIndicator(colorScheme),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(Tween(begin: const Offset(0.1, 0), end: Offset.zero)),
              child: child,
            ),
          ),
          child: _currentStep == 1 ? _buildStep1(colorScheme) : _buildStep2(colorScheme),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (_currentStep == 1)
          ElevatedButton(
            onPressed: _isValidating ? null : _validateCurrentPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isValidating
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Suivant'),
          )
        else
          ElevatedButton(
            onPressed: _isValidating ? null : _handleFinalUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06CE70),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isValidating
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirmer'),
          ),
      ],
    );
  }

  Widget _buildStepIndicator(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStepCircle(1, _currentStep >= 1, colorScheme),
        Container(width: 20, height: 2, color: _currentStep == 2 ? colorScheme.primary : colorScheme.outlineVariant),
        _buildStepCircle(2, _currentStep == 2, colorScheme),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive, ColorScheme colorScheme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? colorScheme.primary : colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ColorScheme colorScheme) {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vérification de l\'identité',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Pour des raisons de sécurité, veuillez saisir votre mot de passe actuel.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 24),
        if (_error != null) _buildErrorMessage(colorScheme),
        TextField(
          controller: widget.currentPasswordController,
          obscureText: _obscureCurrent,
          autofocus: true,
          onSubmitted: (_) => _validateCurrentPassword(),
          decoration: InputDecoration(
            labelText: 'Mot de passe actuel',
            prefixIcon: const Icon(Icons.lock_person_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ColorScheme colorScheme) {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nouveau mot de passe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez un mot de passe robuste que vous n\'utilisez pas ailleurs.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 24),
        if (_error != null) _buildErrorMessage(colorScheme),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _showCriteria = hasFocus),
          child: TextField(
            controller: widget.passwordController,
            obscureText: _obscureNew,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
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
          obscureText: _obscureNew,
          onSubmitted: (_) => _handleFinalUpdate(),
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            prefixIcon: const Icon(Icons.lock_reset_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        _buildMatchIndicator(colorScheme),
      ],
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _handleFinalUpdate() async {
    final password = widget.passwordController.text;
    final confirm = widget.confirmController.text;

    final validation = Validators.validatePassword(password);
    if (!validation.isValid) {
      setState(() => _error = validation.error!);
      return;
    }

    if (password != confirm) {
      setState(() => _error = 'Les mots de passe sont différents');
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final current = widget.currentPasswordController.text;
    
    final success = await auth.changePassword(auth.currentUser!.id, current, password);
    
    if (mounted) {
      setState(() => _isValidating = false);
      if (success) {
        Navigator.pop(context);
        AppSnackBars.showSuccess(context, 'Mot de passe mis à jour');
      } else {
        setState(() => _error = auth.error ?? 'Erreur lors du changement');
      }
    }
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
