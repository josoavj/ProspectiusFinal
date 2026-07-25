import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/secure_storage_service.dart';
import '../../services/mysql_service.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isDatabaseConfigured = prefs.getBool('db_configured') ?? false;

    if (!mounted) return;

    if (!isDatabaseConfigured) {
      Navigator.of(context).pushReplacementNamed('/config');
    } else {
      try {
        final host = prefs.getString('db_host') ?? 'localhost';
        final port = int.parse(prefs.getString('db_port') ?? '3306');
        final user = prefs.getString('db_user') ?? '';
        final password = await SecureStorageService().getDbPassword() ?? '';
        final database = prefs.getString('db_name') ?? 'Prospectius';

        if (!mounted) return;

        final config = MySQLConfig(
          host: host,
          port: port,
          user: user,
          password: password,
          database: database,
        );

        final authProvider = context.read<AuthProvider>();
        final connected = await authProvider.configureDatabase(config);

        if (!mounted) return;

        if (connected) {
          if (authProvider.isAuthenticated) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/config');
        }
      } catch (e) {
        Navigator.of(context).pushReplacementNamed('/config');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
