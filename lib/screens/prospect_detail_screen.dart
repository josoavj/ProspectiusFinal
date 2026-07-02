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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentProspect = widget.prospect;
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                title: Text(
                  _currentProspect.fullName,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.4),
                            colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Hero(
                        tag: 'prospect_avatar_${_currentProspect.id}',
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            _currentProspect.prenom.isNotEmpty ? _currentProspect.prenom[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _handleUpdate,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: _handleDelete,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(icon: Icon(Icons.info_outline), text: 'Infos'),
                    Tab(icon: Icon(Icons.task_alt), text: 'Tâches'),
                    Tab(icon: Icon(Icons.description_outlined), text: 'Docs'),
                    Tab(icon: Icon(Icons.history), text: 'Suivi'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),
            _buildTasksTab(),
            _buildDocumentsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, child) {
        if (_tabController.index == 1) {
          return FloatingActionButton.extended(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add_task),
            label: const Text('Tâche'),
          );
        }
        if (_tabController.index == 2) {
          return FloatingActionButton.extended(
            onPressed: _handleAddDocument,
            icon: const Icon(Icons.upload_file),
            label: const Text('Fichier'),
          );
        }
        if (_tabController.index == 3) {
          return FloatingActionButton.extended(
            onPressed: _showAddInteractionDialog,
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Interaction'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusAndPriorityRow(),
          const SizedBox(height: 24),
          _buildSectionTitle('Coordonnées'),
          _buildContactCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Entreprise & Digital'),
          _buildDigitalCard(),
          const SizedBox(height: 24),
          if (_currentProspect.description != null && _currentProspect.description!.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            _buildDescriptionCard(),
          ],
          const SizedBox(height: 24),
          _buildSectionTitle('Champs Personnalisés'),
          _buildCustomFieldsList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatusAndPriorityRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoBadge(
            label: 'Statut',
            value: TextFormatter.formatStatus(_currentProspect.status),
            color: _getStatusColor(_currentProspect.status),
            icon: Icons.sync,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoBadge(
            label: 'Priorité',
            value: _currentProspect.priorite.toUpperCase(),
            color: _getPriorityColor(_currentProspect.priorite),
            icon: Icons.priority_high,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge({required String label, required String value, required Color color, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Email', _currentProspect.email, Icons.email_outlined),
            const Divider(height: 24),
            _buildDetailRow('Téléphone', _currentProspect.telephone, Icons.phone_outlined),
            const Divider(height: 24),
            _buildDetailRow('Adresse', _currentProspect.adresse, Icons.location_on_outlined),
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
            _buildDetailRow('Entreprise', _currentProspect.nomEntreprise ?? '-', Icons.business_outlined),
            const Divider(height: 24),
            _buildDetailRow('Poste', _currentProspect.poste ?? '-', Icons.work_outline),
            const Divider(height: 24),
            _buildDetailRow('Source', _currentProspect.source ?? '-', Icons.source_outlined),
            const Divider(height: 24),
            _buildDetailRow('Site Web', _currentProspect.siteWeb ?? '-', Icons.language_outlined),
            const Divider(height: 24),
            _buildDetailRow('LinkedIn', _currentProspect.linkedinUrl ?? '-', Icons.link_outlined),
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
        child: Text(
          _currentProspect.description ?? '',
          style: const TextStyle(height: 1.6, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildCustomFieldsList() {
    return Consumer<CustomFieldProvider>(
      builder: (context, provider, _) {
        final values = provider.getValues(_currentProspect.id);
        if (provider.fields.isEmpty) return const Center(child: Text('Aucun champ défini', style: TextStyle(fontSize: 12)));

        return Column(
          children: provider.fields.map((field) {
            final value = values.firstWhere((v) => v.idField == field.id, 
              orElse: () => CustomFieldValue(idProspect: _currentProspect.id, idField: field.id, value: '')).value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: ListTile(
                  dense: true,
                  title: Text(field.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(value.isEmpty ? 'Non renseigné' : value),
                  trailing: const Icon(Icons.edit_outlined, size: 16),
                  onTap: () => _showEditCustomFieldDialog(field, value),
                ),
              ),
            );
          }).toList(),
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
              ? _buildEmptyState(Icons.task_alt, 'Aucune tâche prévue')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      opacity: 1,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: task.isCompleted,
                          onChanged: (val) => provider.toggleTaskStatus(task),
                          title: Text(task.title, style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                          )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description.isNotEmpty) Text(task.description, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 12, color: colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Échéance: ${task.dueDate.day}/${task.dueDate.month}',
                                    style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          secondary: IconButton(
                            icon: Icon(Icons.delete_outline, color: colorScheme.error), 
                            onPressed: () => provider.deleteTask(task.id, _currentProspect.id)
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<DocumentProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: provider.documents.isEmpty
              ? _buildEmptyState(Icons.description_outlined, 'Aucun document')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.documents.length,
                  itemBuilder: (context, index) {
                    final doc = provider.documents[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.insert_drive_file_outlined, color: colorScheme.primary),
                        ),
                        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${(doc.size / 1024).toStringAsFixed(1)} KB • Ajouté le ${doc.creation.day}/${doc.creation.month}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline), 
                          onPressed: () => provider.deleteDocument(doc.id, _currentProspect.id)
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onTap: () {
                          // Action pour ouvrir le document
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<ProspectProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: provider.interactions.isEmpty
              ? _buildEmptyState(Icons.forum_outlined, 'Aucun historique d\'échanges')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = provider.interactions[index];
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: index == provider.interactions.length - 1 ? Colors.transparent : colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(_getInteractionIcon(interaction.type), size: 16, color: colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Text(
                                                TextFormatter.formatInteractionType(interaction.type),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${interaction.dateInteraction.day}/${interaction.dateInteraction.month} à ${interaction.dateInteraction.hour}:${interaction.dateInteraction.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(interaction.note, style: const TextStyle(fontSize: 14, height: 1.4)),
                                      if (interaction.suivi != null && interaction.suivi!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.assignment_turned_in_outlined, size: 14, color: Colors.green),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'À faire: ${interaction.suivi}',
                                                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
              Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
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
          title: const Text('Nouvel Échange'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type d\'interaction', border: OutlineInputBorder()),
                    items: ['appel', 'email', 'reunion', 'message', 'autre'].map((t) => DropdownMenuItem(value: t, child: Text(TextFormatter.formatInteractionType(t)))).toList(),
                    onChanged: (val) => setDialogState(() => type = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: newStatus,
                    decoration: const InputDecoration(labelText: 'Modifier le Statut', border: OutlineInputBorder()),
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
                        decoration: const InputDecoration(labelText: 'Assigné à', border: OutlineInputBorder()),
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
                    decoration: const InputDecoration(labelText: 'Note de l\'échange', border: OutlineInputBorder(), hintText: 'Que s\'est-il passé ?'), 
                    minLines: 4, maxLines: 6,
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: suiviController, 
                    decoration: const InputDecoration(labelText: 'Action de suivi (optionnel)', border: OutlineInputBorder(), hintText: 'Ex: Rappeler vendredi'), 
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
                  userRole: authProvider.currentUser!.typeCompte,
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
        content: const Text('Êtes-vous sûr ? Cette action est irréversible.'),
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
      final auth = context.read<AuthProvider>();
      final success = await context.read<ProspectProvider>().deleteProspect(
        auth.currentUser!.id,
        auth.currentUser!.typeCompte,
        _currentProspect.id,
      );
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
      case 'appel': return Icons.call_outlined;
      case 'email': return Icons.email_outlined;
      case 'réunion': return Icons.people_outline;
      default: return Icons.chat_bubble_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau': return Colors.blue;
      case 'interesse': return Colors.amber;
      case 'negociation': return Colors.orange;
      case 'converti': return const Color(0xFF06CE70);
      case 'perdu': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute': return Colors.red;
      case 'moyenne': return Colors.orange;
      default: return Colors.blue;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
