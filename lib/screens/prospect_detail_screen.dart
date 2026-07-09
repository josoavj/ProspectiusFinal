import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prospect.dart';
import '../models/task.dart';
import '../models/document.dart' as doc_model;
import '../models/custom_field.dart';
import '../models/account.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../providers/task_provider.dart';
import '../providers/document_provider.dart';
import '../providers/custom_field_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import '../utils/app_logger.dart';
import '../core/theme/app_colors.dart';
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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Pour mettre à jour le FAB selon l'onglet
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final id = _currentProspect.id;
    context.read<ProspectProvider>().loadInteractions(id);
    context.read<TaskProvider>().loadTasks(id);
    context.read<DocumentProvider>().loadDocuments(id);
    context.read<ProspectProvider>().loadStatusHistory(id);
    context.read<CustomFieldProvider>().loadValuesForProspect(id);
    context.read<CustomFieldProvider>().loadFields();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 280.0, // Plus d'espace pour éviter les coupures
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                iconTheme: IconThemeData(color: colorScheme.primary), // Icônes visibles
                actionsIconTheme: IconThemeData(color: colorScheme.primary),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 82), // Remonté pour ne plus être coupé
                  title: Text(
                    _currentProspect.fullName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 26, // Imposant mais équilibré
                      letterSpacing: -1.0,
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
                        bottom: 80, // Aligné visuellement avec le centre du texte
                        right: 24,
                        child: Hero(
                          tag: 'prospect_avatar_${_currentProspect.id}',
                          child: CircleAvatar(
                            radius: 46, // Plus grand pour plus de prestance
                            backgroundColor: colorScheme.primary,
                            child: Text(
                              _currentProspect.prenom.isNotEmpty ? _currentProspect.prenom[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _handleUpdate, tooltip: 'Modifier'),
                  IconButton(icon: Icon(Icons.delete_outline, color: colorScheme.error), onPressed: _handleDelete, tooltip: 'Supprimer'),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      indicatorColor: colorScheme.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Infos'),
                        Tab(icon: Icon(Icons.task_alt, size: 20), text: 'Tâches'),
                        Tab(icon: Icon(Icons.description_outlined, size: 20), text: 'Docs'),
                        Tab(icon: Icon(Icons.route_outlined, size: 20), text: 'Parcours'),
                        Tab(icon: Icon(Icons.history, size: 20), text: 'Suivi'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(_buildInfoTab(), 'info'),
            _buildTabContent(_buildTasksTab(), 'tasks'),
            _buildTabContent(_buildDocumentsTab(), 'docs'),
            _buildTabContent(_buildStatusHistoryTab(), 'parcours'),
            _buildTabContent(_buildHistoryTab(), 'history'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTabContent(Widget child, String key) {
    return Builder(
      builder: (context) => CustomScrollView(
        key: PageStorageKey(key),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    );
  }

  Widget? _buildFab() {
    if (_tabController.index == 0 || _tabController.index == 3) return null;
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabController.index == 1) _showAddTaskDialog();
        if (_tabController.index == 2) _handleAddDocument();
        if (_tabController.index == 4) _showAddInteractionDialog();
      },
      icon: Icon(_tabController.index == 1 ? Icons.add_task : 
                 _tabController.index == 2 ? Icons.upload_file : Icons.add_comment_outlined),
      label: Text(_tabController.index == 1 ? 'Tâche' : 
                  _tabController.index == 2 ? 'Fichier' : 'Interaction'),
    );
  }

  Widget _buildInfoTab() {
    final type = _currentProspect.type.toLowerCase();
    final isParticulier = type == 'particulier';
    final isOrganisation = type == 'organisation';
    
    String sectionTitle = 'Entreprise & Digital';
    if (isParticulier) sectionTitle = 'Source & Digital';
    if (isOrganisation) sectionTitle = 'Organisation & Digital';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusAndPriorityRow(),
          const SizedBox(height: 24),
          _buildSectionTitle('Coordonnées'),
          _buildContactCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(sectionTitle),
          _buildDigitalCard(),
          const SizedBox(height: 24),
          if (_currentProspect.description?.isNotEmpty ?? false) ...[
            _buildSectionTitle('Description'),
            _buildDescriptionCard(),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle('RGPD & Conformité'),
          _buildRGPDCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Champs Personnalisés'),
          _buildCustomFieldsList(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), overflow: TextOverflow.ellipsis),
              ],
            ),
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
    final type = _currentProspect.type.toLowerCase();
    final isParticulier = type == 'particulier';
    final isOrganisation = type == 'organisation';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isParticulier) ...[
              _buildDetailRow(
                isOrganisation ? 'Organisation' : 'Entreprise', 
                _currentProspect.nomEntreprise ?? '-', 
                isOrganisation ? Icons.account_balance_outlined : Icons.business_outlined
              ),
              const Divider(height: 24),
              _buildDetailRow('Poste', _currentProspect.poste ?? '-', Icons.work_outline),
              const Divider(height: 24),
            ],
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

  Widget _buildRGPDCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = _currentProspect.consentementDate != null 
        ? '${_currentProspect.consentementDate!.day}/${_currentProspect.consentementDate!.month}/${_currentProspect.consentementDate!.year}'
        : 'Non renseignée';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Date Consentement', dateStr, Icons.calendar_today_outlined),
            const Divider(height: 24),
            _buildDetailRow('Source Consentement', _currentProspect.consentementSource ?? 'Non renseignée', Icons.verified_user_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_currentProspect.description ?? '', style: const TextStyle(height: 1.6, fontSize: 14)),
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return Card(
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
                                Text('Échéance: ${task.dueDate.day}/${task.dueDate.month}', style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        secondary: IconButton(icon: Icon(Icons.delete_outline, color: colorScheme.error), onPressed: () => provider.deleteTask(task.id, _currentProspect.id)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.documents.length,
                  itemBuilder: (context, index) {
                    final doc = provider.documents[index];
                    final isImage = ['png', 'jpg', 'jpeg'].contains(doc.mimeType.toLowerCase());
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                          child: isImage 
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(doc.filePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(_getFileIcon(doc.mimeType), color: colorScheme.primary)))
                            : Icon(_getFileIcon(doc.mimeType), color: colorScheme.primary),
                        ),
                        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${(doc.size / 1024).toStringAsFixed(1)} KB • Ajouté le ${doc.createdAt.day}/${doc.createdAt.month}'),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => provider.deleteDocument(doc.id, _currentProspect.id)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onTap: () => isImage ? _showImagePreview(doc) : _openDocument(doc),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildStatusHistoryTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<ProspectProvider>(
      builder: (context, provider, _) {
        return SimpleStateBuilder(
          isLoading: provider.isLoading,
          error: provider.error,
          child: provider.statusHistory.isEmpty
              ? _buildEmptyState(Icons.route_outlined, 'Aucun changement de statut enregistré')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.statusHistory.length,
                  itemBuilder: (context, index) {
                    final history = provider.statusHistory[index];
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(history.newStatus),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.surface, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(history.newStatus).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: index == provider.statusHistory.length - 1 
                                      ? Colors.transparent 
                                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(history.newStatus).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          TextFormatter.formatStatus(history.newStatus).toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(history.newStatus),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${history.changedAt.day}/${history.changedAt.month} à ${history.changedAt.hour}:${history.changedAt.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: colorScheme.onSurface, fontSize: 14, height: 1.4),
                                      children: [
                                        const TextSpan(text: 'Passage de '),
                                        TextSpan(
                                          text: TextFormatter.formatStatus(history.oldStatus ?? 'Inconnu'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const TextSpan(text: ' à '),
                                        TextSpan(
                                          text: TextFormatter.formatStatus(history.newStatus),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(history.newStatus),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 14, color: colorScheme.outline),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Modifié par: ${history.changedByName ?? "Utilisateur #${history.changedBy}"}',
                                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ],
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.interactions.length,
                  itemBuilder: (context, index) {
                    final interaction = provider.interactions[index];
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                              Expanded(child: Container(width: 2, color: index == provider.interactions.length - 1 ? Colors.transparent : colorScheme.outlineVariant)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                                ),
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
                                              Icon(_getInteractionIcon(interaction.type), size: 18, color: colorScheme.primary),
                                              const SizedBox(width: 10),
                                              Text(TextFormatter.formatInteractionType(interaction.type), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            ],
                                          ),
                                          Text('${interaction.dateInteraction.day}/${interaction.dateInteraction.month} à ${interaction.dateInteraction.hour}:${interaction.dateInteraction.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(interaction.note, style: const TextStyle(fontSize: 14, height: 1.5)),
                                      if (interaction.suivi?.isNotEmpty ?? false) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.assignment_turned_in_outlined, size: 14, color: Colors.green),
                                              const SizedBox(width: 10),
                                              Expanded(child: Text('Suivi: ${interaction.suivi}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600))),
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
                  TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note de l\'échange', border: OutlineInputBorder(), hintText: 'Que s\'est-il passé ?'), minLines: 4, maxLines: 6, onChanged: (val) => setDialogState(() {})),
                  const SizedBox(height: 16),
                  TextField(controller: suiviController, decoration: const InputDecoration(labelText: 'Action de suivi (optionnel)', border: OutlineInputBorder(), hintText: 'Ex: Rappeler vendredi'), minLines: 2, maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: noteController.text.isEmpty ? null : () async {
                await prospectProvider.createInteractionComplex(
                  prospectId: _currentProspect.id, userId: authProvider.currentUser!.id, userRole: authProvider.currentUser!.typeCompte,
                  type: type, note: noteController.text, date: DateTime.now(), idAssigne: selectedAssigneId, suivi: suiviController.text, newStatus: newStatus,
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

  void _handleAddDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      if (pickedFile.path == null) return;

      final originalFile = File(pickedFile.path!);
      final appDocDir = await getApplicationDocumentsDirectory();
      
      // Utilisation de path.join serait idéal, mais on simule ici pour Windows
      final String sep = Platform.isWindows ? '\\' : '/';
      final prospectDocsDir = Directory('${appDocDir.path}${sep}prospect_documents$sep${_currentProspect.id}');

      if (!prospectDocsDir.existsSync()) {
        prospectDocsDir.createSync(recursive: true);
      }
      final String fileName = pickedFile.name;
      final String newPath = '${prospectDocsDir.path}$sep$fileName';
      await originalFile.copy(newPath);
      final document = doc_model.Document(id: 0, idProspect: _currentProspect.id, name: fileName, filePath: newPath, mimeType: pickedFile.extension ?? 'unknown', size: pickedFile.size, createdAt: DateTime.now());
      if (mounted) {
        final success = await context.read<DocumentProvider>().addDocument(document);
        if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document ajouté avec succès')));
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'ajout du document: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  void _showEditCustomFieldDialog(CustomField field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${field.name}'),
        content: SizedBox(width: 400, child: TextField(controller: controller, decoration: InputDecoration(labelText: field.name, border: const OutlineInputBorder()), autofocus: true)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () { context.read<CustomFieldProvider>().saveValue(_currentProspect.id, field.id, controller.text); Navigator.pop(context); }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  void _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final success = await context.read<ProspectProvider>().deleteProspect(auth.currentUser!.id, auth.currentUser!.typeCompte, _currentProspect.id);
      if (success && mounted) Navigator.pop(context);
    }
  }

  void _handleUpdate() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProspectScreen(prospect: _currentProspect))).then((updated) {
      if (updated != null && updated is Prospect) setState(() => _currentProspect = updated);
      _loadData();
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'doc': case 'docx': return Icons.description_outlined;
      case 'xls': case 'xlsx': return Icons.table_chart_outlined;
      case 'png': case 'jpg': case 'jpeg': return Icons.image_outlined;
      case 'txt': return Icons.article_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  void _showImagePreview(doc_model.Document doc) {
    showDialog(context: context, builder: (context) => Dialog(backgroundColor: Colors.transparent, child: Stack(alignment: Alignment.topRight, children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(doc.filePath))), IconButton.filled(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: Colors.black54))])));
  }

  Future<void> _openDocument(doc_model.Document doc) async {
    final file = File(doc.filePath);
    if (!file.existsSync()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fichier introuvable'), backgroundColor: Colors.red));
      return;
    }
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [doc.filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [doc.filePath]);
      } else if (Platform.isWindows) {
        await Process.run('start', ['', doc.filePath], runInShell: true);
      }
    } catch (e) {
      AppLogger.error('Erreur d\'ouverture: $e');
    }
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
      case 'nouveau': return AppColors.azure;
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
      default: return AppColors.azure;
    }
  }
}

class _TabKeepAlive extends StatefulWidget {
  final Widget child;
  const _TabKeepAlive({required this.child});
  @override State<_TabKeepAlive> createState() => _TabKeepAliveState();
}

class _TabKeepAliveState extends State<_TabKeepAlive> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
  @override Widget build(BuildContext context) { super.build(context); return widget.child; }
}
