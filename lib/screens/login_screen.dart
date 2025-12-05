import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/rate_limit_service.dart';
import '../utils/app_logger.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final RateLimitService _rateLimitService;

  @override
  void initState() {
    super.initState();
    _rateLimitService = RateLimitService();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();

    // Vérifier le rate limit avant la tentative
    try {
      final locked = await _rateLimitService.isAccountLocked(username);
      if (locked) {
        final remaining =
            await _rateLimitService.getLockoutTimeRemaining(username);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Compte verrouillé. Réessayez dans ${remaining ?? 0} secondes',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    } catch (e) {
      AppLogger.error('Erreur vérification rate limit', e);
      if (!mounted) return;
    }

    // ignore: use_build_context_synchronously
    final authProvider = context.read<AuthProvider>();

    try {
      final success =
          await authProvider.login(username, _passwordController.text);

      if (!mounted) return;

      if (success) {
        // Réinitialiser les compteurs après connexion réussie
        await _rateLimitService.recordSuccessfulLogin(username);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ),
          );
        }
      } else {
        // Enregistrer la tentative échouée
        try {
          await _rateLimitService.recordFailedAttempt(username);
        } on RateLimitException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: e.retryAfterSeconds),
              ),
            );
          }
          AppLogger.warning('Rate limit atteint: ${e.code}');
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion', e);
      try {
        await _rateLimitService.recordFailedAttempt(username);
      } catch (e) {
        // Déjà géré via RateLimitException
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_center,
                      size: 80, color: Colors.blue[700]),
                  const SizedBox(height: 24),
                  Text(
                    'Prospectius',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestion de Prospects CRM',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Connexion',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte? '),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
