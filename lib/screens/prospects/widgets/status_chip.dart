import 'package:flutter/material.dart';
import '../../../utils/text_formatter.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color chipColor;
    
    switch (status.toLowerCase()) {
      case 'interesse': chipColor = Colors.amber; break;
      case 'negociation': chipColor = Colors.orange; break;
      case 'converti': chipColor = const Color(0xFF06CE70); break;
      case 'perdu': chipColor = Colors.red; break;
      default: chipColor = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        TextFormatter.formatStatus(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
