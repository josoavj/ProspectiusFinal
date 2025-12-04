import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../utils/app_logger.dart';

class AuditTransferScreen extends StatefulWidget {
  final int prospectId;

  const AuditTransferScreen({
    Key? key,
    required this.prospectId,
  }) : super(key: key);

  @override
  State<AuditTransferScreen> createState() => _AuditTransferScreenState();
}

class _AuditTransferScreenState extends State<AuditTransferScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditNotifier>().loadAuditHistory(widget.prospectId);
      context.read<TransferNotifier>().loadTransferHistory(widget.prospectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audit et Transferts'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Historique d\'audit'),
              Tab(text: 'Transferts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet Audit
            _buildAuditTab(context),
            // Onglet Transferts
            _buildTransfersTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTab(BuildContext context) {
    return Consumer<AuditNotifier>(
      builder: (context, auditNotifier, child) {
        if (auditNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (auditNotifier.error != null) {
          return Center(
            child: Text('Erreur: ${auditNotifier.error}'),
          );
        }

        if (auditNotifier.auditHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun événement d\'audit'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: auditNotifier.auditHistory.length,
          itemBuilder: (context, index) {
            final audit = auditNotifier.auditHistory[index];
            final action = audit['action'] as String?;
            final description = audit['description'] as String?;
            final createdAt = audit['created_at'] as String?;

            IconData icon;
            Color color;

            switch (action) {
              case 'INSERT':
                icon = Icons.add_circle;
                color = Colors.green;
                break;
              case 'UPDATE':
                icon = Icons.edit;
                color = Colors.blue;
                break;
              case 'DELETE':
                icon = Icons.delete;
                color = Colors.red;
                break;
              default:
                icon = Icons.info;
                color = Colors.grey;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(action ?? 'Inconnu'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(description ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      createdAt ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransfersTab(BuildContext context) {
    return Consumer<TransferNotifier>(
      builder: (context, transferNotifier, child) {
        if (transferNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transferNotifier.error != null) {
          return Center(
            child: Text('Erreur: ${transferNotifier.error}'),
          );
        }

        if (transferNotifier.transferHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.compare_arrows, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun transfert'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transferNotifier.transferHistory.length,
          itemBuilder: (context, index) {
            final transfer = transferNotifier.transferHistory[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const Icon(Icons.compare_arrows, color: Colors.orange),
                title: Text(
                  'Transfert #${transfer.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${transfer.transferDate?.toString() ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'De:',
                          'User #${transfer.fromUserId}',
                        ),
                        _buildInfoRow(
                          'À:',
                          'User #${transfer.toUserId}',
                        ),
                        if (transfer.transferReason != null)
                          _buildInfoRow(
                            'Raison:',
                            transfer.transferReason!,
                          ),
                        if (transfer.transferNotes != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Notes:',
                            transfer.transferNotes!,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Statut:',
                          transfer.status,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
