import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prospect_provider.dart';
import '../../providers/stats_provider.dart';
import '../prospects/prospects_screen.dart';
import '../dashboard/pipeline_screen.dart';
import '../dashboard/exploration_screen.dart';
import '../dashboard/stats_screen.dart';
import '../prospects/clients_screen.dart';
import '../prospects/export_prospects_screen.dart';
import '../misc/about_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/configuration_screen.dart';
import '../settings/logs_viewer_screen.dart';
import '../prospects/add_prospect_screen.dart';
import '../../widgets/sidebar_navigation.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class NewProspectIntent extends Intent {
  const NewProspectIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onRefresh() {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;
    final role = auth.currentUser?.typeCompte;

    if (userId == null || role == null) return;

    switch (_selectedIndex) {
      case 0:
      case 1:
      case 2:
      case 4:
        context.read<ProspectProvider>().loadProspects(userId, role);
        break;
      case 3:
        context.read<StatsProvider>().loadAllStats(userId, role);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const NewProspectIntent(),
        LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const CloseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<SearchIntent>(onInvoke: (intent) {
            setState(() => _selectedIndex = 2);
            return null;
          }),
          NewProspectIntent: CallbackAction<NewProspectIntent>(onInvoke: (intent) {
            AddProspectScreen.show(context);
            return null;
          }),
          RefreshIntent: CallbackAction<RefreshIntent>(onInvoke: (intent) {
            _onRefresh();
            return null;
          }),
          CloseIntent: CallbackAction<CloseIntent>(onInvoke: (intent) {
            Navigator.maybePop(context);
            return null;
          }),
        },
        child: Scaffold(
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
        ),
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Prospects';
      case 1:
        return 'Pipeline';
      case 2:
        return 'Exploration & Filtres';
      case 3:
        return 'Statistiques Globales';
      case 4:
        return 'Clients';
      case 5:
        return 'Exporter';
      case 6:
        return 'À propos';
      case 7:
        return 'Mon Profil';
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
