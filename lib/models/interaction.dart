class Interaction {
  final int id;
  final int idProspect;
  final int idCompte;
  final String type;
  final String note;
  final DateTime dateInteraction;

  Interaction({
    required this.id,
    required this.idProspect,
    required this.idCompte,
    required this.type,
    required this.note,
    required this.dateInteraction,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id_interaction'] as int,
      idProspect: json['id_prospect'] as int,
      idCompte: json['id_compte'] as int,
      type: json['type'] as String? ?? '',
      note: json['note'] as String? ?? '',
      dateInteraction: DateTime.parse(json['date_interaction'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_interaction': id,
        'id_prospect': idProspect,
        'id_compte': idCompte,
        'type': type,
        'note': note,
        'date_interaction': dateInteraction.toIso8601String(),
      };
}
