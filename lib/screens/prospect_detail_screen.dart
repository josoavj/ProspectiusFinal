import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import 'edit_prospect_screen.dart';

class ProspectDetailScreen extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailScreen({super.key, required this.prospect});

  @override
  State<ProspectDetailScreen> createState() => _ProspectDetailScreenState();
}

class _ProspectDetailScreenState extends State<ProspectDetailScreen> {
  late Prospect _currentProspect;

  @override
  void initState() {
    super.initState();
    _currentProspect = widget.prospect;
    // Load interactions after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final prospectProvider = context.read<ProspectProvider>();
    prospectProvider.loadInteractions(_currentProspect.id);
  }

  void _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce prospect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final prospectProvider = context.read<ProspectProvider>();

      if (authProvider.currentUser != null) {
        final success = await prospectProvider.deleteProspect(
          authProvider.currentUser!.id,
          _currentProspect.id,
        );
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _handleUpdate() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => EditProspectScreen(prospect: _currentProspect),
      ),
    )
        .then((updatedProspect) {
      if (updatedProspect != null && updatedProspect is Prospect) {
        setState(() {
          _currentProspect = updatedProspect;
        });
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProspect.fullName),
        elevation: 0,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                _handleDelete();
              } else if (value == 'audit') {
                Navigator.of(context).pushNamed(
                  '/audit_transfer',
                  arguments: _currentProspect.id,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'audit',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Audit et transferts'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Informations du prospect
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TextFormatter.capitalize(
                                    _currentProspect.fullName),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                TextFormatter.formatType(_currentProspect.type),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(TextFormatter.formatStatus(
                              _currentProspect.status)),
                          backgroundColor: _getStatusColor(
                            _currentProspect.status,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildInfoRow('Email', _currentProspect.email),
                    _buildInfoRow('Téléphone', _currentProspect.telephone),
                    _buildInfoRow('Adresse', _currentProspect.adresse),
                    _buildInfoRow(
                      'Créé le',
                      '${_currentProspect.creation.day}/${_currentProspect.creation.month}/${_currentProspect.creation.year}',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _handleUpdate,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: const Text('Mettre à jour',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Historique des interactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Interactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Liste des interactions
            Consumer<ProspectProvider>(
              builder: (context, prospectProvider, _) {
                return SimpleStateBuilder(
                  isLoading: prospectProvider.isLoading,
                  error: prospectProvider.error,
                  child: prospectProvider.interactions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Aucune interaction',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: prospectProvider.interactions.length,
                          itemBuilder: (context, index) {
                            final interaction =
                                prospectProvider.interactions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  _getInteractionIcon(interaction.type),
                                ),
                                title: Text(
                                    TextFormatter.capitalize(interaction.type)),
                                subtitle: Text(interaction.note),
                                trailing: Text(
                                  '${interaction.dateInteraction.day}/${interaction.dateInteraction.month}/${interaction.dateInteraction.year}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  IconData _getInteractionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appel':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'réunion':
        return Icons.people;
      default:
        return Icons.message;
    }
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
        return const Color.fromARGB(255, 6, 206, 112).withOpacity(0.1);
      case 'perdu':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
