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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _statuses.map((status) {
                  final prospects = provider.prospects.where((p) => p.status == status).toList();
                  return _buildPipelineColumn(status, prospects);
                }).toList(),
              ),
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
          width: 300,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? colorScheme.primary.withValues(alpha: 0.1) 
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty ? colorScheme.primary : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TextFormatter.formatStatus(status).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
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
              Divider(height: 1, color: colorScheme.outlineVariant),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: prospects.length,
                  itemBuilder: (context, index) {
                    final prospect = prospects[index];
                    return Draggable<Prospect>(
                      data: prospect,
                      feedback: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 276,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.primary, width: 2),
                          ),
                          child: Text(
                            prospect.fullName,
                            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surface,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: prospect)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prospect.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  TextFormatter.formatType(prospect.type),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: colorScheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      'Créé le ${prospect.creation.day}/${prospect.creation.month}',
                      style: TextStyle(fontSize: 11, color: colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
