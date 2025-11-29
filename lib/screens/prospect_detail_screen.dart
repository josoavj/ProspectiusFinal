import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import 'add_prospect_screen.dart';

class ProspectDetailScreen extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailScreen({Key? key, required this.prospect})
    : super(key: key);

  @override
  State<ProspectDetailScreen> createState() => _ProspectDetailScreenState();
}

class _ProspectDetailScreenState extends State<ProspectDetailScreen> {
  final _descriptionController = TextEditingController();
  String _selectedType = 'Appel';

  @override
  void initState() {
    super.initState();
    _loadInteractions();
  }

  void _loadInteractions() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    prospectProvider.loadInteractions(widget.prospect.id);
  }

  void _handleAddInteraction() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    await prospectProvider.createInteraction(
      widget.prospect.id,
      authProvider.currentUser!.id,
      _selectedType,
      _descriptionController.text,
      DateTime.now(),
    );

    _descriptionController.clear();
    _loadInteractions();
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

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      final prospectProvider = context.read<ProspectProvider>();

      if (authProvider.currentUser != null) {
        final success = await prospectProvider.deleteProspect(
          authProvider.currentUser!.id,
          widget.prospect.id,
        );
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prospect.fullName),
        elevation: 0,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddProspectScreen(prospect: widget.prospect),
                      ),
                    )
                    .then((_) => _loadInteractions());
              } else if (value == 'delete') {
                _handleDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Éditer'),
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
                    _buildInfoRow('Email', widget.prospect.email),
                    _buildInfoRow('Téléphone', widget.prospect.telephone),
                    _buildInfoRow('Entreprise', widget.prospect.entreprise),
                    _buildInfoRow('Poste', widget.prospect.poste),
                    _buildInfoRow('Statut', widget.prospect.statut),
                    _buildInfoRow('Source', widget.prospect.source),
                    if (widget.prospect.notes.isNotEmpty)
                      _buildInfoRow('Notes', widget.prospect.notes),
                  ],
                ),
              ),
            ),
            // Interactions
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
            // Formulaire d'ajout d'interaction
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 'Appel';
                        });
                      },
                      items: ['Appel', 'Email', 'Réunion', 'Message']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Type d\'interaction',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleAddInteraction,
                        child: const Text('Ajouter interaction'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Liste des interactions
            Consumer<ProspectProvider>(
              builder: (context, prospectProvider, _) {
                if (prospectProvider.interactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucune interaction',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prospectProvider.interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = prospectProvider.interactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getInteractionIcon(interaction.typeInteraction),
                        ),
                        title: Text(interaction.typeInteraction),
                        subtitle: Text(interaction.description),
                        trailing: Text(
                          '${interaction.dateInteraction.day}/${interaction.dateInteraction.month}/${interaction.dateInteraction.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
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
}
