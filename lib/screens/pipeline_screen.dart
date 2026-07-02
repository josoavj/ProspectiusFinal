import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import 'prospect_detail_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final List<String> _statuses = ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProspects();
    });
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
        builder: (context, provider, _) {
          return SimpleStateBuilder(
            isLoading: provider.isLoading && provider.prospects.isEmpty,
            error: provider.error,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Adaptation dynamique : sur très grand écran, on occupe tout l'espace
                final isWideScreen = constraints.maxWidth > 1600;
                
                final content = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _statuses.map((status) {
                    final prospects = provider.prospects.where((p) => p.status == status).toList();
                    final column = _buildPipelineColumn(status, prospects);
                    return isWideScreen ? Expanded(child: column) : column;
                  }).toList(),
                );

                return isWideScreen 
                  ? Padding(padding: const EdgeInsets.all(12.0), child: content)
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12.0),
                      child: content,
                    );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPipelineColumn(String status, List<Prospect> prospects) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(status);

    return DragTarget<Prospect>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final prospect = details.data;
        final authProvider = context.read<AuthProvider>();
        context.read<ProspectProvider>().updateProspectStatus(
          authProvider.currentUser!.id,
          prospect.id,
          status,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 320, // Largeur par défaut en mode scroll
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? colorScheme.primary.withValues(alpha: 0.1) 
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: candidateData.isNotEmpty ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TextFormatter.formatStatus(status).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${prospects.length}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  itemCount: prospects.length,
                  itemBuilder: (context, index) {
                    final prospect = prospects[index];
                    return Draggable<Prospect>(
                      data: prospect,
                      feedback: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 290,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.primary, width: 2),
                          ),
                          child: Text(
                            prospect.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: _buildProspectCard(prospect),
                      ),
                      child: _buildProspectCard(prospect),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProspectCard(Prospect prospect) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _getPriorityColor(prospect.priorite);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: prospect)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicateur de priorité latéral
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                prospect.nom.isNotEmpty ? prospect.nom[0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                prospect.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TextFormatter.formatType(prospect.type),
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 10, color: colorScheme.outline),
                                const SizedBox(width: 4),
                                Text(
                                  '${prospect.creation.day}/${prospect.creation.month}',
                                  style: TextStyle(fontSize: 10, color: colorScheme.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute': return Colors.redAccent;
      case 'moyenne': return Colors.orangeAccent;
      default: return Colors.blueAccent;
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
}
