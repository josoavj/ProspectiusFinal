import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../models/task.dart';
import '../models/custom_field.dart';
import '../models/account.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../providers/task_provider.dart';
import '../providers/document_provider.dart';
import '../providers/custom_field_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import 'edit_prospect_screen.dart';

class ProspectDetailScreen extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailScreen({super.key, required this.prospect});

  @override
  State<ProspectDetailScreen> createState() => _ProspectDetailScreenState();
}

class _ProspectDetailScreenState extends State<ProspectDetailScreen> with SingleTickerProviderStateMixin {
  late Prospect _currentProspect;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentProspect = widget.prospect;
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final id = _currentProspect.id;
    context.read<ProspectProvider>().loadInteractions(id);
    context.read<TaskProvider>().loadTasks(id);
    context.read<DocumentProvider>().loadDocuments(id);
    context.read<CustomFieldProvider>().loadValuesForProspect(id);
    context.read<CustomFieldProvider>().loadFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProspect.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _handleUpdate,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleDelete,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Infos', icon: Icon(Icons.info_outline)),
            Tab(text: 'Tâches', icon: Icon(Icons.task_alt)),
            Tab(text: 'Documents', icon: Icon(Icons.description_outlined)),
            Tab(text: 'Champs Perso', icon: Icon(Icons.add_box_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildTasksTab(),
          _buildDocumentsTab(),
          _buildCustomFieldsTab(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, child) {
        if (_tabController.index == 1) {
          return FloatingActionButton(
            onPressed: _showAddTaskDialog,
            child: const Icon(Icons.add_task),
          );
        }
        if (_tabController.index == 2) {
          return FloatingActionButton(
            onPressed: _handleAddDocument,
            child: const Icon(Icons.upload_file),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          Text('Interactions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildInteractionsList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextFormatter.formatType(_currentProspect.type),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Chip(
                  label: Text(TextFormatter.formatStatus(_currentProspect.status)),
                  backgroundColor: _getStatusColor(_currentProspect.status),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Email', _currentProspect.email),
            _buildInfoRow('Téléphone', _currentProspect.telephone),
            _buildInfoRow('Adresse', _currentProspect.adresse),
            _buildInfoRow('Assigné à ID', _currentProspect.assignation.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsList() {
    return Consumer<ProspectProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showAddInteractionDialog,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('Ajouter un échange'),
                ),
              ),
              provider.interactions.isEmpty
                  ? const Center(child: Text('Aucune interaction'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.interactions.length,
                      itemBuilder: (context, index) {
                        final interaction = provider.interactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.blue[50],
                                          child: Icon(_getInteractionIcon(interaction.type), size: 14, color: Colors.blue),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          TextFormatter.formatInteractionType(interaction.type),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${interaction.dateInteraction.day}/${interaction.dateInteraction.month} à ${interaction.dateInteraction.hour}:${interaction.dateInteraction.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  interaction.note,
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                                if (interaction.suivi != null && interaction.suivi!.isNotEmpty) ...[
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      const Icon(Icons.assignment_turned_in_outlined, size: 14, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'À faire: ${interaction.suivi}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: provider.tasks.isEmpty
              ? const Center(child: Text('Aucune tâche prévue'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return CheckboxListTile(
                      title: Text(task.title, style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      )),
                      subtitle: Text('${task.description}\nÉchéance: ${task.dueDate.day}/${task.dueDate.month}'),
                      value: task.isCompleted,
                      onChanged: (val) => provider.toggleTaskStatus(task),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => provider.deleteTask(task.id, _currentProspect.id),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return Consumer<DocumentProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: provider.documents.isEmpty
              ? const Center(child: Text('Aucun document'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.documents.length,
                  itemBuilder: (context, index) {
                    final doc = provider.documents[index];
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(doc.name),
                      subtitle: Text('${(doc.size / 1024).toStringAsFixed(1)} KB'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => provider.deleteDocument(doc.id, _currentProspect.id),
                      ),
                      onTap: () {
                        // Action pour ouvrir le document (url_launcher ou autre)
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildCustomFieldsTab() {
    return Consumer<CustomFieldProvider>(
      builder: (context, provider, _) {
        final values = provider.getValues(_currentProspect.id);
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.fields.length,
            itemBuilder: (context, index) {
              final field = provider.fields[index];
              final value = values.firstWhere((v) => v.idField == field.id,
                orElse: () => CustomFieldValue(idProspect: _currentProspect.id, idField: field.id, value: '')).value;

              return ListTile(
                title: Text(field.name),
                subtitle: Text(value.isEmpty ? 'Non renseigné' : value),
                trailing: const Icon(Icons.edit, size: 16),
                onTap: () => _showEditCustomFieldDialog(field, value),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddInteractionDialog() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    final noteController = TextEditingController();
    final suiviController = TextEditingController();
    String type = 'appel';
    int? selectedAssigneId;
    String newStatus = _currentProspect.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle Interaction'),
          content: SizedBox(
            width: 500, // Largeur fixe pour éviter les sauts d'interface
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['appel', 'email', 'reunion', 'message', 'autre'].map((t) => DropdownMenuItem(value: t, child: Text(TextFormatter.formatInteractionType(t)))).toList(),
                    onChanged: (val) => setDialogState(() => type = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: newStatus,
                    decoration: const InputDecoration(labelText: 'Nouveau Statut'),
                    items: ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'].map((s) => DropdownMenuItem(value: s, child: Text(TextFormatter.formatStatus(s)))).toList(),
                    onChanged: (val) => setDialogState(() => newStatus = val!),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Account>>(
                    future: authProvider.getAllUsers(),
                    builder: (context, snapshot) {
                      final users = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        initialValue: selectedAssigneId,
                        decoration: const InputDecoration(labelText: 'Assigné à (optionnel)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Personne')),
                          ...users.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.fullName)))
                        ],
                        onChanged: (val) => setDialogState(() => selectedAssigneId = val),
                      );
                    }
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController, 
                    decoration: const InputDecoration(
                      labelText: 'Note de l\'échange',
                      hintText: 'Que s\'est-il passé ?',
                    ), 
                    minLines: 4,
                    maxLines: 6, // Limite la croissance en hauteur
                    onChanged: (val) => setDialogState(() {}), // Pour activer le bouton Enregistrer
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: suiviController, 
                    decoration: const InputDecoration(
                      labelText: 'Suivi / Action à faire',
                      hintText: 'Ex: Rappeler dans 2 jours',
                    ), 
                    minLines: 2,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: noteController.text.isEmpty
                  ? null
                  : () async {
                      await prospectProvider.createInteractionComplex(
                        prospectId: _currentProspect.id,
                        userId: authProvider.currentUser!.id,
                        type: type,
                        note: noteController.text,
                        date: DateTime.now(),
                        idAssigne: selectedAssigneId,
                        suivi: suiviController.text,
                        newStatus: newStatus,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadData();
                    },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController, 
                decoration: const InputDecoration(labelText: 'Titre de la tâche'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController, 
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Détails du rappel...',
                ),
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;
              context.read<TaskProvider>().addTask(Task(
                id: 0,
                idProspect: _currentProspect.id,
                title: titleController.text,
                description: descController.text,
                dueDate: DateTime.now().add(const Duration(days: 1)),
                createdAt: DateTime.now(),
              ));
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _handleAddDocument() {
    // Dans une vraie app, on utiliserait file_picker
    // Ici on simule l'ajout pour la démo si nécessaire, ou on implémente si possible
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélection de fichier non implémentée (nécessite file_picker)')));
  }

  void _showEditCustomFieldDialog(CustomField field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${field.name}'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller, 
            decoration: InputDecoration(
              labelText: field.name,
              hintText: 'Saisissez la valeur...',
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              context.read<CustomFieldProvider>().saveValue(_currentProspect.id, field.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ... helper methods from original file ...
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
      case 'appel': return Icons.call;
      case 'email': return Icons.email;
      case 'réunion': return Icons.people;
      default: return Icons.message;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau': return Colors.blue[100]!;
      case 'interesse': return Colors.amber[100]!;
      case 'negociation': return Colors.orange[100]!;
      case 'converti': return Colors.green[100]!;
      case 'perdu': return Colors.red[100]!;
      default: return Colors.grey[100]!;
    }
  }

  void _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce prospect?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final success = await context.read<ProspectProvider>().deleteProspect(
          authProvider.currentUser!.id,
          _currentProspect.id,
        );
        if (success && mounted) Navigator.of(context).pop();
      }
    }
  }

  void _handleUpdate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditProspectScreen(prospect: _currentProspect)),
    ).then((updatedProspect) {
      if (updatedProspect != null && updatedProspect is Prospect) {
        setState(() { _currentProspect = updatedProspect; });
        _loadData();
      }
    });
  }
}
