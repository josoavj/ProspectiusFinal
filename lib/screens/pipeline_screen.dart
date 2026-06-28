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
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : Colors.transparent,
              width: 2,
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${prospects.length}',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: prospects.length,
                  itemBuilder: (context, index) {
                    final prospect = prospects[index];
                    return Draggable<Prospect>(
                      data: prospect,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Text(prospect.fullName),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProspectDetailScreen(prospect: prospect),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prospect.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                prospect.type,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Créé le ${prospect.creation.day}/${prospect.creation.month}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
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
      case 'converti': return Colors.green;
      case 'perdu': return Colors.red;
      default: return Colors.grey;
    }
  }
}
