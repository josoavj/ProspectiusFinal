import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/audit_provider.dart';

class TransferStatsWidget extends StatefulWidget {
  final int userId;

  const TransferStatsWidget({
    super.key,
    required this.userId,
  });

  @override
  State<TransferStatsWidget> createState() => _TransferStatsWidgetState();
}

class _TransferStatsWidgetState extends State<TransferStatsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransferNotifier>().loadTransferStats(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransferNotifier>(
      builder: (context, transferNotifier, child) {
        final stats = transferNotifier.transferStats;
        final received = stats['received'] as int? ?? 0;
        final sent = stats['sent'] as int? ?? 0;
        final owned = stats['owned'] as int? ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.azure.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.azure.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistiques de Transfert',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    icon: Icons.input,
                    label: 'Reçus',
                    value: received.toString(),
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.output,
                    label: 'Envoyés',
                    value: sent.toString(),
                    color: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.folder,
                    label: 'Possédés',
                    value: owned.toString(),
                    color: AppColors.azure,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
