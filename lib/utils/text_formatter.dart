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

  /// Formate un numéro de téléphone malgache (+261 XX XXX XX) depuis le format de stockage (261XXXXXXX)
  static String formatPhone(String phone) {
    if (phone.isEmpty) return phone;
    
    // Si c'est une liste de numéros
    if (phone.contains(',')) {
      return phone.split(', ').map((p) => formatPhone(p)).join(', ');
    }

    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Format attendu en base : 261XXXXXXX (10 chiffres)
    if (cleaned.length == 10 && cleaned.startsWith('261')) {
      String local = cleaned.substring(3);
      return '+261 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 7)}';
    }
    
    // Fallback si déjà formaté ou autre
    if (cleaned.length == 7) {
      return '+261 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)}';
    }

    return phone;
  }
}

/// Formatter pour la saisie de téléphone malgache (7 chiffres après le préfixe)
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    
    // On ne garde que les chiffres
    String cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // On ignore le préfixe s'il est saisi
    if (cleaned.startsWith('261') && cleaned.length > 3) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('0') && cleaned.length > 1) {
      cleaned = cleaned.substring(1);
    }

    // LIMITE STRICTE : 7 chiffres (format XX XXX XX)
    if (cleaned.length > 7) cleaned = cleaned.substring(0, 7);

    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      // Format: XX XXX XX
      if (i == 2 || i == 5) formatted += ' ';
      formatted += cleaned[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
