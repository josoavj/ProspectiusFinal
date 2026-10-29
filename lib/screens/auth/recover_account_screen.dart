import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';
import 'widgets/auth_page_shell.dart';

class RecoverAccountScreen extends StatefulWidget {
  const RecoverAccountScreen({super.key});

  @override
  State<RecoverAccountScreen> createState() => _RecoverAccountScreenState();
}

class _RecoverAccountScreenState extends State<RecoverAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = Validators.validatePassword(_passwordController.text);
    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPasswordWithRecoveryCode(
      _emailController.text.trim(),
      _codeController.text.trim().toUpperCase(),
      _passwordController.text,
    );
    if (!mounted || !success) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mot de passe réinitialisé'),
        content: const Text('Votre nom d’utilisateur a été récupéré et votre nouveau mot de passe est actif.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => AuthPageShell(
        form: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthFormHeader(
                eyebrow: 'Récupération sécurisée',
                title: 'Récupérer votre compte',
                subtitle: 'Utilisez le code remis lors de la création du premier administrateur.',
              ),
              const SizedBox(height: 16),
              _RecoveryInformationCard(
                title: 'Comment fonctionne la récupération ?',
                content:
                    'Le code de récupération est remis uniquement lors de la création du premier administrateur, ou après sa régénération depuis le profil administrateur. Il ne doit jamais être partagé ni enregistré dans l’application.',
              ),
              const SizedBox(height: 28),
              AuthTextField(
                controller: _emailController,
                label: 'Adresse e-mail de l’administrateur',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validators.validateEmail(value?.trim() ?? '').error,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _codeController,
                label: 'Code de récupération',
                icon: Icons.key_outlined,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Le code de récupération est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: 'Nouveau mot de passe',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Le nouveau mot de passe est obligatoire' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirmer le nouveau mot de passe',
                icon: Icons.lock_reset_outlined,
                obscureText: _obscurePassword,
                validator: (value) =>
                    value != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 18),
                Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _recover,
                  child: auth.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Réinitialiser le mot de passe'),
                ),
              ),
            ],
          ),
        ),
        footer: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour à la connexion'),
        ),
      ),
    );
  }
}

class _RecoveryInformationCard extends StatelessWidget {
  final String title;
  final String content;

  const _RecoveryInformationCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
