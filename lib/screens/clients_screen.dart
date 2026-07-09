import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../utils/text_formatter.dart';
import '../widgets/data_state_widget.dart';
import 'prospect_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClients();
    });
  }

  void _loadClients() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser != null) {
      prospectProvider.loadProspects(
        authProvider.currentUser!.id,
        authProvider.currentUser!.typeCompte,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: prospectProvider.isLoading ? null : _loadClients,
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
                  child: _buildClientsList(prospectProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientsList(ProspectProvider prospectProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clientColor = const Color(0xFF06CE70);
    
    final clients = prospectProvider.prospects
        .where((prospect) => prospect.status == 'converti')
        .toList();

    if (clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: clientColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_outlined, size: 80, color: clientColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Félicitations pour vos succès !',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'C\'est ici que vous retrouverez tous vos prospects convertis en clients. Continuez vos efforts pour remplir cette liste !',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // On ouvre le drawer pour aider l'utilisateur à naviguer
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Convertir de nouveaux prospects'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: clients.length,
      itemBuilder: (context, index) => _buildClientListItem(context, clients[index]),
    );
  }

  Widget _buildClientListItem(BuildContext context, Prospect client) {
    final colorScheme = Theme.of(context).colorScheme;
    final clientColor = const Color(0xFF06CE70);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProspectDetailScreen(prospect: client)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'client_avatar_${client.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [clientColor, clientColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        client.prenom.isNotEmpty ? client.prenom[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TextFormatter.capitalize(client.fullName),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_center_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              client.nomEntreprise ?? 'Particulier',
                              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: clientColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: clientColor),
                          const SizedBox(width: 4),
                          Text(
                            'ACTIF',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: clientColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
