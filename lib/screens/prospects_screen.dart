import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import 'add_prospect_screen.dart';
import 'prospect_detail_screen.dart';

class ProspectsScreen extends StatefulWidget {
  const ProspectsScreen({Key? key}) : super(key: key);

  @override
  State<ProspectsScreen> createState() => _ProspectsScreenState();
}

class _ProspectsScreenState extends State<ProspectsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProspects();
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
          if (prospectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prospectProvider.prospects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun prospect',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
            );
          }

          return ListView.builder(
            itemCount: prospectProvider.prospects.length,
            itemBuilder: (context, index) {
              final prospect = prospectProvider.prospects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text(prospect.prenom[0])),
                  title: Text(prospect.fullName),
                  subtitle: Text(
                    prospect.entreprise.isEmpty
                        ? prospect.email
                        : prospect.entreprise,
                  ),
                  trailing: Chip(
                    label: Text(prospect.statut),
                    backgroundColor: _getStatusColor(prospect.statut),
                  ),
                  onTap: () {
                    context.read<ProspectProvider>().selectProspect(prospect);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProspectDetailScreen(prospect: prospect),
                      ),
                    );
                  },
                ),
              );
            },
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
        icon: const Icon(Icons.add),
        label: const Text('Nouveau prospect'),
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue[100]!;
      case 'converti':
        return Colors.green[100]!;
      case 'perdu':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
