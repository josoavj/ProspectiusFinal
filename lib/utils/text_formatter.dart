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

  /// Formate le statut avec majuscule au début
  static String formatStatus(String status) {
    return capitalize(status);
  }

  /// Formate le type avec majuscule au début
  static String formatType(String type) {
    return capitalize(type);
  }

  /// Formate une date pour l'affichage
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
