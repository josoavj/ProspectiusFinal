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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProspect.fullName),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _handleUpdate),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _handleDelete),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
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
        if (_tabController.index == 1) return FloatingActionButton(onPressed: _showAddTaskDialog, child: const Icon(Icons.add_task));
        if (_tabController.index == 2) return FloatingActionButton(onPressed: _handleAddDocument, child: const Icon(Icons.upload_file));
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
          _buildSectionTitle('Digital & Réseaux'),
          _buildDigitalCard(),
          const SizedBox(height: 24),
          if (_currentProspect.description != null && _currentProspect.description!.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            _buildDescriptionCard(),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle('Historique des Interactions'),
          const SizedBox(height: 8),
          _buildInteractionsList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TextFormatter.formatType(_currentProspect.type), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    if (_currentProspect.nomEntreprise != null) 
                      Text(_currentProspect.nomEntreprise!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                _buildPriorityBadge(_currentProspect.priorite),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Email', _currentProspect.email, Icons.email_outlined),
            _buildInfoRow('Téléphone', _currentProspect.telephone, Icons.phone_outlined),
            _buildInfoRow('Adresse', _currentProspect.adresse, Icons.location_on_outlined),
            _buildInfoRow('Statut', TextFormatter.formatStatus(_currentProspect.status), Icons.sync),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Source', _currentProspect.source ?? 'Non définie', Icons.source_outlined),
            _buildInfoRow('Site Web', _currentProspect.siteWeb ?? '-', Icons.language_outlined),
            _buildInfoRow('LinkedIn', _currentProspect.linkedinUrl ?? '-', Icons.link_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_currentProspect.description ?? '', style: const TextStyle(height: 1.5)),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'haute': color = Colors.red; break;
      case 'moyenne': color = Colors.orange; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: color.withValues(alpha: 0.5))
      ),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isEmpty ? '-' : value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildInteractionsList() {
    final colorScheme = Theme.of(context).colorScheme;
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
                                          backgroundColor: colorScheme.primaryContainer,
                                          child: Icon(_getInteractionIcon(interaction.type), size: 14, color: colorScheme.onPrimaryContainer),
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
                                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
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
                                            color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(task.title, style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                        )),
                        subtitle: Text('${task.description}\nÉchéance: ${task.dueDate.day}/${task.dueDate.month}'),
                        value: task.isCompleted,
                        onChanged: (val) => provider.toggleTaskStatus(task),
                        secondary: IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error), 
                          onPressed: () => provider.deleteTask(task.id, _currentProspect.id)
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(doc.name),
                        subtitle: Text('${(doc.size / 1024).toStringAsFixed(1)} KB'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline), 
                          onPressed: () => provider.deleteDocument(doc.id, _currentProspect.id)
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(field.name),
                  subtitle: Text(value.isEmpty ? 'Non renseigné' : value),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _showEditCustomFieldDialog(field, value),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: ['appel', 'email', 'reunion', 'message', 'autre'].map((t) => DropdownMenuItem(value: t, child: Text(TextFormatter.formatInteractionType(t)))).toList(),
                    onChanged: (val) => setDialogState(() => type = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: newStatus,
                    decoration: const InputDecoration(labelText: 'Nouveau Statut', border: OutlineInputBorder()),
                    items: ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'].map((s) => DropdownMenuItem(value: s, child: Text(TextFormatter.formatStatus(s)))).toList(),
                    onChanged: (val) => setDialogState(() => newStatus = val!),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Account>>(
                    future: authProvider.getAllUsers(),
                    builder: (context, snapshot) {
                      final users = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        initialValue: selectedAssigneId,
                        decoration: const InputDecoration(labelText: 'Assigné à (optionnel)', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Personne')),
                          ...users.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.fullName)))
                        ],
                        onChanged: (val) => setDialogState(() => selectedAssigneId = val),
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController, 
                    decoration: const InputDecoration(labelText: 'Note de l\'échange', border: OutlineInputBorder()), 
                    minLines: 4, maxLines: 6,
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: suiviController, 
                    decoration: const InputDecoration(labelText: 'Suivi / Action à faire', border: OutlineInputBorder()), 
                    minLines: 2, maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: noteController.text.isEmpty ? null : () async {
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
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre de la tâche', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), minLines: 3, maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;
              context.read<TaskProvider>().addTask(Task(id: 0, idProspect: _currentProspect.id, title: titleController.text, description: descController.text, dueDate: DateTime.now().add(const Duration(days: 1)), createdAt: DateTime.now()));
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _handleAddDocument() { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélection de fichier non implémentée'))); }

  void _showEditCustomFieldDialog(CustomField field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${field.name}'),
        content: SizedBox(
          width: 400,
          child: TextField(controller: controller, decoration: InputDecoration(labelText: field.name, border: const OutlineInputBorder()), autofocus: true),
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

  void _handleDelete() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final success = await context.read<ProspectProvider>().deleteProspect(context.read<AuthProvider>().currentUser!.id, _currentProspect.id);
      if (success && mounted) Navigator.pop(context);
    }
  }

  void _handleUpdate() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProspectScreen(prospect: _currentProspect))).then((updated) {
      if (updated != null && updated is Prospect) setState(() => _currentProspect = updated);
      _loadData();
    });
  }

  IconData _getInteractionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appel': return Icons.call;
      case 'email': return Icons.email;
      case 'réunion': return Icons.people;
      default: return Icons.message;
    }
  }
}
