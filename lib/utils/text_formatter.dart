/// Classe utilitaire pour formater le texte
class TextFormatter {
  /// Formate le texte pour avoir une majuscule au début de chaque mot
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formate le statut avec majuscule et accents corrects
  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'nouveau':
        return 'Nouveau';
      case 'interesse':
        return 'Intéressé';
      case 'negociation':
        return 'Négociation';
      case 'converti':
        return 'Converti';
      case 'perdu':
        return 'Perdu';
      default:
        return capitalize(status);
    }
  }

  /// Formate le type de prospect avec accents
  static String formatType(String type) {
    switch (type.toLowerCase()) {
      case 'particulier':
        return 'Particulier';
      case 'societe':
        return 'Société';
      case 'organisation':
        return 'Organisation';
      default:
        return capitalize(type);
    }
  }

  /// Formate le type d'interaction
  static String formatInteractionType(String type) {
    switch (type.toLowerCase()) {
      case 'appel':
        return 'Appel';
      case 'email':
        return 'Email';
      case 'reunion':
        return 'Réunion';
      case 'message':
        return 'Message';
      case 'sms':
        return 'SMS';
      case 'autre':
        return 'Autre';
      default:
        return capitalize(type);
    }
  }

  /// Formate la priorité
  static String formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'basse':
        return 'Basse';
      case 'moyenne':
        return 'Moyenne';
      case 'haute':
        return 'Haute';
      default:
        return capitalize(priority);
    }
  }

  /// Formate une date pour l'affichage
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
