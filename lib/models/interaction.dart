class Interaction {
  final int id;
  final int idProspect;
  final int idUtilisateur;
  final String typeInteraction;
  final String description;
  final DateTime dateInteraction;
  final DateTime dateCreation;

  Interaction({
    required this.id,
    required this.idProspect,
    required this.idUtilisateur,
    required this.typeInteraction,
    required this.description,
    required this.dateInteraction,
    required this.dateCreation,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as int,
      idProspect: json['id_prospect'] as int,
      idUtilisateur: json['id_utilisateur'] as int,
      typeInteraction: json['type_interaction'] as String,
      description: json['description'] as String,
      dateInteraction: DateTime.parse(json['date_interaction'] as String),
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_prospect': idProspect,
    'id_utilisateur': idUtilisateur,
    'type_interaction': typeInteraction,
    'description': description,
    'date_interaction': dateInteraction.toIso8601String(),
    'date_creation': dateCreation.toIso8601String(),
  };
}
