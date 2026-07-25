import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prospect_provider.dart';
import '../../services/excel_service.dart';
import '../../widgets/data_state_widget.dart';
import '../../utils/app_snackbars.dart';
import 'add_prospect_screen.dart';
import 'prospect_detail_screen.dart';
import 'widgets/prospect_list_item.dart';

class ProspectsScreen extends StatefulWidget {
  const ProspectsScreen({super.key});

  @override
  State<ProspectsScreen> createState() => _ProspectsScreenState();
}

class _ProspectsScreenState extends State<ProspectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProspects();
    });
  }

  void _loadProspects() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    if (authProvider.currentUser != null) {
      prospectProvider.loadProspects(
        authProvider.currentUser!.id,
        authProvider.currentUser!.typeCompte,
      );
    }
  }

  void _handleImport() async {
    final excelService = ExcelService();
    final filePath = await excelService.pickImportFile();
    if (filePath != null && mounted) {
      try {
        final prospects = await excelService.importProspectsFromExcel(filePath);
        if (!mounted) return;
        final prospectProvider = context.read<ProspectProvider>();
        final authProvider = context.read<AuthProvider>();
        
        int count = 0;
        for (var data in prospects) {
          data['userId'] = authProvider.currentUser?.id;
          final success = await prospectProvider.createProspect(
            data,
            authProvider.currentUser?.typeCompte ?? 'Utilisateur',
          );
          if (success) count++;
        }
        
        if (mounted) {
          AppSnackBars.showSuccess(context, '$count prospects importés avec succès');
          _loadProspects();
        }
      } catch (e) {
        if (mounted) {
          AppSnackBars.showError(context, 'Erreur lors de l\'import: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _handleImport,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Importer Excel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: prospectProvider.isLoading ? null : _loadProspects,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SimpleStateBuilder(
                  isLoading: prospectProvider.isLoading && prospectProvider.prospects.isEmpty,
                  error: prospectProvider.error,
                  loadingWidget: const SkeletonListLoader(),
                  child: prospectProvider.prospects.isEmpty
                      ? _buildEmptyState(theme, colorScheme)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: prospectProvider.prospects.length,
                          itemBuilder: (context, index) {
                            final prospect = prospectProvider.prospects[index];
                            return ProspectListItem(
                              prospect: prospect,
                              onTap: () {
                                prospectProvider.selectProspect(prospect);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: prospect)),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddProspectScreen.show(context).then((_) => _loadProspects());
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau prospect'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_add_outlined, size: 80, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Commencez votre aventure',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Votre liste de prospects est vide pour le moment. Ajoutez votre premier contact pour commencer à suivre vos opportunités.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Icon(Icons.arrow_downward, color: colorScheme.primary.withValues(alpha: 0.5)),
            Text('Cliquez sur le bouton en bas à droite', 
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
