import 'package:flutter/material.dart';

class PasswordMatchIndicator extends StatelessWidget {
  final bool passwordsMatch;
  final bool isNotEmpty;

  const PasswordMatchIndicator({
    super.key,
    required this.passwordsMatch,
    required this.isNotEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (!isNotEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(
            passwordsMatch ? Icons.check_circle_outline : Icons.error_outline,
            size: 14,
            color: passwordsMatch ? const Color(0xFF06CE70) : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            passwordsMatch ? 'Les mots de passe correspondent' : 'Les mots de passe sont différents',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: passwordsMatch ? const Color(0xFF06CE70) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
