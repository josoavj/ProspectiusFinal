import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
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
    // Utiliser addPostFrameCallback pour éviter setState() pendant le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProspects();
    });
  }

  void _loadProspects() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    if (authProvider.currentUser != null) {
      prospectProvider.loadProspects(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, _) {
          return Column(
            children: [
              // Bouton d'actualisation en haut
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          prospectProvider.isLoading ? null : _loadProspects,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenu principal
              Expanded(
                child: SimpleStateBuilder(
                  isLoading: prospectProvider.isLoading,
                  error: prospectProvider.error,
                  child: prospectProvider.prospects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun prospect',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AddProspectScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un prospect'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: prospectProvider.prospects.length,
                          itemBuilder: (context, index) {
                            final prospect = prospectProvider.prospects[index];
                            return _buildProspectListItem(
                                context, prospect, prospectProvider);
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
              .push(
                MaterialPageRoute(builder: (_) => const AddProspectScreen()),
              )
              .then((_) => _loadProspects());
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau prospect'),
      ),
    );
  }

  Widget _buildProspectListItem(BuildContext context, Prospect prospect,
      ProspectProvider prospectProvider) {
    return GestureDetector(
      onTap: () {
        prospectProvider.selectProspect(prospect);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProspectDetailScreen(prospect: prospect),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue[500],
            child: Text(
              prospect.prenom.isNotEmpty
                  ? prospect.prenom[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            TextFormatter.capitalize(prospect.fullName),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            prospect.email.isEmpty ? '-' : prospect.email,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(prospect.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              TextFormatter.formatStatus(prospect.status),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau':
        return Colors.blue[600]!;
      case 'interesse':
        return Colors.amber[600]!;
      case 'negociation':
        return Colors.orange[600]!;
      case 'converti':
        return const Color.fromARGB(255, 6, 206, 112);
      case 'perdu':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
