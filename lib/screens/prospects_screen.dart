import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import 'add_prospect_screen.dart';
import 'prospect_detail_screen.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

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

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: prospectProvider.prospects.length,
            itemBuilder: (context, index) {
              final prospect = prospectProvider.prospects[index];
              return _buildProspectCard(context, prospect, prospectProvider);
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau prospect'),
      ),
    );
  }

  Widget _buildProspectCard(BuildContext context, Prospect prospect,
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
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  prospect.prenom.isNotEmpty
                      ? prospect.prenom[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                prospect.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  prospect.type.capitalize(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Status
              Chip(
                label: Text(
                  prospect.status.capitalize(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w500),
                ),
                backgroundColor: _getStatusColor(prospect.status),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau':
        return Colors.blue[100]!;
      case 'interesse':
        return Colors.amber[100]!;
      case 'negociation':
        return Colors.orange[100]!;
      case 'converti':
        return Colors.green[100]!;
      case 'perdu':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
