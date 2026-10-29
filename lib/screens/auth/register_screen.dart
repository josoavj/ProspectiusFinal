import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_snackbars.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';
import 'widgets/auth_page_shell.dart';
import '../../services/recovery_code_export_service.dart';
import 'widgets/password_criteria_widget.dart';
import 'widgets/password_match_indicator.dart';
import '../legal/legal_document_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isBootstrap;
  final bool embedded;

  const RegisterScreen({
    super.key,
    this.isBootstrap = false,
    this.embedded = false,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showCriteria = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _passwordsMatch = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordCriteria);
    _confirmPasswordController.addListener(_updatePasswordCriteria);
  }

  void _updatePasswordCriteria() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (!mounted) return;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _passwordsMatch = password.isNotEmpty && password == confirm;
      _localError = null;
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, String label) {
    final result = Validators.validateName(value?.trim() ?? '', label);
    return result.isValid ? null : result.error;
  }

  Future<void> _handleRegister() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _localError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    final passwordValidation =
        Validators.validatePassword(_passwordController.text);
    if (!passwordValidation.isValid) {
      setState(() => _localError = passwordValidation.error);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _localError = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (!_acceptedTerms || !_acceptedPrivacy) {
      setState(() => _localError =
          'Vous devez accepter les conditions d’utilisation et la politique de confidentialité');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final recoveryCode = widget.isBootstrap
        ? await authProvider.registerFirstAdmin(
            _nomController.text.trim(),
            _prenomController.text.trim(),
            _emailController.text.trim(),
            _usernameController.text.trim(),
            _passwordController.text,
          )
        : (await authProvider.register(
            _nomController.text.trim(),
            _prenomController.text.trim(),
            _emailController.text.trim(),
            _usernameController.text.trim(),
            _passwordController.text,
          )
            ? 'standard'
            : null);

    if (!mounted || recoveryCode == null) return;
    if (widget.isBootstrap) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Code de récupération administrateur'),
          content: SelectableText(
            'Notez ce code et conservez-le hors de l’application. Il ne sera plus affiché :\n\n$recoveryCode',
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                try {
                  final saved =
                      await RecoveryCodeExportService.save(recoveryCode);
                  if (context.mounted && saved != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Code enregistré dans le fichier texte.')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Impossible d’enregistrer le code : $error')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Télécharger en .txt'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('J’ai conservé le code'),
            ),
          ],
        ),
      );
    }
    AppSnackBars.showSuccess(context,
        'Inscription réussie ! Vous pouvez maintenant vous connecter.');
    if (widget.embedded) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final error = _localError ?? auth.error;
        return AuthPageShell(
          showBrandPanel: !widget.embedded,
          form: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthFormHeader(
                  eyebrow: widget.isBootstrap
                      ? 'Configuration initiale'
                      : 'Inscription',
                  title: widget.isBootstrap
                      ? 'Créer le premier administrateur'
                      : 'Créer votre compte',
                  subtitle: widget.isBootstrap
                      ? 'Ce compte administrera cette base de données locale.'
                      : 'Quelques informations suffisent pour commencer.',
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateName(value, 'Le prénom'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        controller: _nomController,
                        label: 'Nom',
                        icon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateName(value, 'Le nom'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _emailController,
                  label: 'Adresse e-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final result =
                        Validators.validateEmail(value?.trim() ?? '');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _usernameController,
                  label: 'Nom d’utilisateur',
                  icon: Icons.alternate_email_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final result =
                        Validators.validateUsername(value?.trim() ?? '');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) =>
                      setState(() => _showCriteria = hasFocus),
                  child: AuthTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Afficher le mot de passe'
                          : 'Masquer le mot de passe',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Le mot de passe est obligatoire'
                        : null,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showCriteria
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: PasswordCriteriaWidget(
                            hasMinLength: _hasMinLength,
                            hasUppercase: _hasUppercase,
                            hasLowercase: _hasLowercase,
                            hasDigits: _hasDigits,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_reset_outlined,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value != _passwordController.text
                      ? 'Les mots de passe ne correspondent pas'
                      : null,
                ),
                PasswordMatchIndicator(
                  passwordsMatch: _passwordsMatch,
                  isNotEmpty: _confirmPasswordController.text.isNotEmpty,
                ),
                const SizedBox(height: 18),
                _LegalAcceptance(
                  acceptedTerms: _acceptedTerms,
                  acceptedPrivacy: _acceptedPrivacy,
                  onTermsChanged: (value) =>
                      setState(() => _acceptedTerms = value),
                  onPrivacyChanged: (value) =>
                      setState(() => _acceptedPrivacy = value),
                ),
                if (error != null) ...[
                  const SizedBox(height: 18),
                  _AuthErrorMessage(message: error),
                ],
                const SizedBox(height: 26),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isBootstrap
                            ? 'Créer l’administrateur initial'
                            : 'Créer mon compte'),
                  ),
                ),
              ],
            ),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Vous avez déjà un compte ?',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              TextButton(
                onPressed: () {
                  if (widget.embedded) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalAcceptance extends StatelessWidget {
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;

  const _LegalAcceptance({
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  void _open(BuildContext context, LegalDocumentType type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        CheckboxListTile(
          value: acceptedTerms,
          onChanged: (value) => onTermsChanged(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text.rich(
            TextSpan(
              text: 'J’accepte les ',
              children: [
                TextSpan(
                  text: 'Conditions d’utilisation',
                  style: TextStyle(
                      color: colors.primary, fontWeight: FontWeight.w700),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _open(context, LegalDocumentType.terms),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        CheckboxListTile(
          value: acceptedPrivacy,
          onChanged: (value) => onPrivacyChanged(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text.rich(
            TextSpan(
              text: 'J’ai lu la ',
              children: [
                TextSpan(
                  text: 'Politique de confidentialité',
                  style: TextStyle(
                      color: colors.primary, fontWeight: FontWeight.w700),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _open(context, LegalDocumentType.privacy),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthErrorMessage extends StatelessWidget {
  final String message;

  const _AuthErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(message, style: TextStyle(color: colors.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
