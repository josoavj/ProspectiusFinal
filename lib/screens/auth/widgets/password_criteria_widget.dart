import 'package:flutter/material.dart';

class PasswordCriteriaWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigits;

  const PasswordCriteriaWidget({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigits,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCriteriaItem('8 caractères minimum', hasMinLength, colorScheme),
          _buildCriteriaItem('Une majuscule (A-Z)', hasUppercase, colorScheme),
          _buildCriteriaItem('Une minuscule (a-z)', hasLowercase, colorScheme),
          _buildCriteriaItem('Un chiffre (0-9)', hasDigits, colorScheme),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String label, bool isMet, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? const Color(0xFF06CE70) : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
