import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/prospect_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/database_config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/prospects_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/sidebar_navigation.dart';

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
    final authProvider = context.read<AuthProvider>();
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/prospects');
    } else {
      Navigator.of(context).pushReplacementNamed('/config');
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
        return 'Statistiques';
      case 2:
        return 'Configuration';
      default:
        return 'Prospectius';
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const ProspectsScreen();
      case 1:
        return const StatsScreen();
      case 2:
        return const Center(
          child: Text('Bientôt disponible'),
        );
      default:
        return const ProspectsScreen();
    }
  }
}
