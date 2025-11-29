import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import 'prospect_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider =
        Provider.of<ProspectProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      prospectProvider.loadProspects(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, child) {
          if (prospectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = prospectProvider.prospects
              .where((prospect) => prospect.status == 'converti')
              .toList();

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun client converti',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les prospects convertis en clients apparaîtront ici',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
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
            itemCount: clients.length,
            itemBuilder: (context, index) => _buildClientCard(
              context,
              clients[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Prospect client) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProspectDetailScreen(prospect: client),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green[500],
                child: Text(
                  client.prenom[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                client.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
                  client.type.capitalize(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Status badge
              Chip(
                label: const Text(
                  'Converti',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.green[100],
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
