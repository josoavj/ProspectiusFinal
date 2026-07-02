import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';
import 'prospect_detail_screen.dart';
import 'dart:ui';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final List<String> _statuses = ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'];
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProspects());
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
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
                final isWideScreen = constraints.maxWidth > 1400;
                
                final content = Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _statuses.map((status) {
                    final prospects = provider.prospects.where((p) => p.status == status).toList();
                    final column = _buildPipelineColumn(status, prospects, isWideScreen);
                    return isWideScreen ? Expanded(child: column) : column;
                  }).toList(),
                );

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                  ),
                  child: Scrollbar(
                    controller: _horizontalController,
                    thumbVisibility: !isWideScreen,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16.0),
                      child: isWideScreen 
                          ? SizedBox(width: constraints.maxWidth - 32, child: content)
                          : content,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPipelineColumn(String status, List<Prospect> prospects, bool isWideScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(status);

    return DragTarget<Prospect>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final prospect = details.data;
        context.read<ProspectProvider>().updateProspectStatus(
          context.read<AuthProvider>().currentUser!.id,
          prospect.id,
          status,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: isWideScreen ? null : 280,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? colorScheme.primary.withValues(alpha: 0.1) 
                : colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: candidateData.isNotEmpty ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.2),
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
                        fontWeight: FontWeight.w800, 
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${prospects.length}',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: prospects.length,
                  itemBuilder: (context, index) {
                    final prospect = prospects[index];
                    return Draggable<Prospect>(
                      data: prospect,
                      feedback: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.primary, width: 2),
                          ),
                          child: Text(prospect.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: 0.2, child: _buildProspectCard(prospect)),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: prospect))),
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prospect.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TextFormatter.formatType(prospect.type),
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 10, color: colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              '${prospect.creation.day}/${prospect.creation.month}',
                              style: TextStyle(fontSize: 10, color: colorScheme.outline),
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
