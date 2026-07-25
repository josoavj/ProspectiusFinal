import 'package:flutter/material.dart';
import '../../../models/prospect.dart';
import '../../../utils/text_formatter.dart';
import 'status_chip.dart';

class ProspectListItem extends StatelessWidget {
  final Prospect prospect;
  final VoidCallback onTap;

  const ProspectListItem({
    super.key,
    required this.prospect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    prospect.prenom.isNotEmpty ? prospect.prenom[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TextFormatter.capitalize(prospect.fullName),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prospect.email.isEmpty ? 'Aucun email' : prospect.email,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(status: prospect.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
