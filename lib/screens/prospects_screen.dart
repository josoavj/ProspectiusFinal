import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../services/excel_service.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import '../core/theme/app_colors.dart';
import 'add_prospect_screen.dart';
import 'prospect_detail_screen.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$count prospects importés avec succès')),
          );
          _loadProspects();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'import: $e'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  isLoading: prospectProvider.isLoading,
                  error: prospectProvider.error,
                  child: prospectProvider.prospects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun prospect',
                                style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddProspectScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un prospect'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: prospectProvider.prospects.length,
                          itemBuilder: (context, index) {
                            final prospect = prospectProvider.prospects[index];
                            return _buildProspectListItem(context, prospect, prospectProvider);
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
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddProspectScreen()))
              .then((_) => _loadProspects());
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau prospect'),
      ),
    );
  }

  Widget _buildProspectListItem(BuildContext context, Prospect prospect, ProspectProvider prospectProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            prospectProvider.selectProspect(prospect);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: prospect)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    prospect.prenom.isNotEmpty ? prospect.prenom[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TextFormatter.capitalize(prospect.fullName),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prospect.email.isEmpty ? 'Aucun email' : prospect.email,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(prospect.status, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'nouveau': chipColor = AppColors.azure; break;
      case 'interesse': chipColor = Colors.amber; break;
      case 'negociation': chipColor = Colors.orange; break;
      case 'converti': chipColor = const Color(0xFF06CE70); break;
      case 'perdu': chipColor = Colors.red; break;
      default: chipColor = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        TextFormatter.formatStatus(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
