import 'package:flutter/services.dart';

/// Classe utilitaire pour formater le texte
class TextFormatter {
  // ... (existing capitalize)
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ... (existing methods)
  static String formatStatus(String status) => _formatStatus(status);
  static String formatType(String type) => _formatType(type);
  static String formatInteractionType(String type) => _formatInteractionType(type);
  static String formatPriority(String priority) => _formatPriority(priority);
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau': return 'Nouveau';
      case 'interesse': return 'Intéressé';
      case 'negociation': return 'Négociation';
      case 'converti': return 'Converti';
      case 'perdu': return 'Perdu';
      default: return capitalize(status);
    }
  }

  static String _formatType(String type) {
    switch (type.toLowerCase()) {
      case 'particulier': return 'Particulier';
      case 'societe': return 'Société';
      case 'organisation': return 'Organisation';
      default: return capitalize(type);
    }
  }

  static String _formatInteractionType(String type) {
    switch (type.toLowerCase()) {
      case 'appel': return 'Appel';
      case 'email': return 'Email';
      case 'reunion': return 'Réunion';
      case 'message': return 'Message';
      case 'sms': return 'SMS';
      case 'autre': return 'Autre';
      default: return capitalize(type);
    }
  }

  static String _formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'basse': return 'Basse';
      case 'moyenne': return 'Moyenne';
      case 'haute': return 'Haute';
      default: return capitalize(priority);
    }
  }

  /// Formate un numéro de téléphone malgache (+261 XX XXX XX)
  static String formatPhone(String phone) {
    if (phone.isEmpty) return phone;
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (cleaned.startsWith('261')) cleaned = cleaned.substring(3);

    if (cleaned.length == 7) {
      return '+261 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)}';
    } else if (cleaned.length == 9) {
      return '+261 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)}';
    }
    return phone;
  }
}

/// Formatter pour la saisie de téléphone malgache
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length <= oldValue.text.length) return newValue;

    String cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (cleaned.startsWith('261')) cleaned = cleaned.substring(3);

    // Format: XX XXX XX (7 digits) or XX XX XXX XX (9 digits)
    // We'll follow the user's specific request: +261 00 000 00
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i == 2 || i == 5) formatted += ' ';
      formatted += cleaned[i];
      if (i >= 8) break; // Limit to 9 digits
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
