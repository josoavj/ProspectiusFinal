import 'package:flutter/material.dart';
import 'package:prospectius/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/prospect_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/audit_provider.dart';
import 'providers/task_provider.dart';
import 'providers/document_provider.dart';
import 'providers/custom_field_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/database_config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/prospects_screen.dart';
import 'screens/about_screen.dart';
import 'screens/logs_viewer_screen.dart';
import 'screens/exploration_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/export_prospects_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/pipeline_screen.dart';
import 'screens/configuration_screen.dart';
import 'widgets/sidebar_navigation.dart';
import 'services/mysql_service.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du Service Locator (DI)
  await sl.setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProspectProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => AuditNotifier()),
        ChangeNotifierProvider(create: (_) => TransferNotifier()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => CustomFieldProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Prospectius',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.azure,
                primary: AppColors.azure,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.azure,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              textTheme: GoogleFonts.lexendTextTheme(),
              fontFamily: GoogleFonts.lexend().fontFamily,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
              fontFamily: GoogleFonts.lexend().fontFamily,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Color(0xFF1E1E1E),
              ),
            ),
            themeMode: settings.themeMode,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontSizeFactor),
                ),
                child: child!,
              );
            },
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/config': (_) => const DatabaseConfigScreen(),
              '/login': (_) => const LoginScreen(),
              '/prospects': (_) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}

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
      // Pas de configuration, afficher la page de configuration
      Navigator.of(context).pushReplacementNamed('/config');
    } else {
      // Configuration existante, charger la config et se connecter à la DB
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
  const MainScreen({super.key});

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
        return 'Pipeline';
      case 2:
        return 'Exploration';
      case 3:
        return 'Statistiques';
      case 4:
        return 'Clients';
      case 5:
        return 'Exporter';
      case 6:
        return 'À propos';
      case 7:
        return 'Profil';
      case 8:
        return 'Paramètres';
      case 9:
        return 'Logs';
      default:
        return 'Prospectius';
    }
  }

  Widget _getScreen(int index) {
    final userRole = context.read<AuthProvider>().currentUser?.typeCompte;

    switch (index) {
      case 0:
        return const ProspectsScreen();
      case 1:
        return const PipelineScreen();
      case 2:
        return const ExplorationScreen();
      case 3:
        return const StatsScreen();
      case 4:
        return const ClientsScreen();
      case 5:
        return const ExportProspectsScreen();
      case 6:
        return const AboutScreen();
      case 7:
        return const ProfileScreen();
      case 8:
        return const ConfigurationScreen();
      case 9:
        if (userRole == 'Administrateur') {
          return const LogsViewerScreen();
        }
        return const ProspectsScreen();
      default:
        return const ProspectsScreen();
    }
  }
}
