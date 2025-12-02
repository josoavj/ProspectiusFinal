import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/prospect_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/database_config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/prospects_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/export_prospects_screen.dart';
import 'screens/about_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/configuration_screen.dart';
import 'screens/exploration_screen.dart';
import 'widgets/sidebar_navigation.dart';
import 'services/mysql_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProspectProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'Prospectius',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/config': (_) => const DatabaseConfigScreen(),
          '/login': (_) => const LoginScreen(),
          '/prospects': (_) => const MainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

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
      // Pas de configuration, afficher la page de configuration
      Navigator.of(context).pushReplacementNamed('/config');
    } else {
      // Configuration existante, charger la config et se connecter à la DB
      try {
        final host = prefs.getString('db_host') ?? 'localhost';
        final port = int.parse(prefs.getString('db_port') ?? '3306');
        final user = prefs.getString('db_user') ?? 'root';
        final password = prefs.getString('db_password') ?? 'root';
        final database = prefs.getString('db_name') ?? 'Prospectius';

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
          // Connecté avec succès
          if (authProvider.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/prospects');
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {
          // Erreur de connexion, afficher la page de configuration
          Navigator.of(context).pushReplacementNamed('/config');
        }
      } catch (e) {
        // Erreur lors du chargement de la config, afficher la page de configuration
        Navigator.of(context).pushReplacementNamed('/config');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      appBar: AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        elevation: 0,
      ),
      body: _getScreen(_selectedIndex),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Prospects';
      case 1:
        return 'Exploration';
      case 2:
        return 'Statistiques';
      case 3:
        return 'Clients';
      case 4:
        return 'Exporter';
      case 5:
        return 'À propos';
      case 6:
        return 'Profil';
      case 7:
        return 'Paramètres';
      default:
        return 'Prospectius';
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const ProspectsScreen();
      case 1:
        return const ExplorationScreen();
      case 2:
        return const StatsScreen();
      case 3:
        return const ClientsScreen();
      case 4:
        return const ExportProspectsScreen();
      case 5:
        return const AboutScreen();
      case 6:
        return const ProfileScreen();
      case 7:
        return const ConfigurationScreen();
      default:
        return const ProspectsScreen();
    }
  }
}
