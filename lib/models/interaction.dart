class Interaction {
  final int id;
  final int idProspect;
  final int idCompte;
  final int? idAssigne;
  final String type;
  final String note;
  final String? suivi;
  final DateTime dateInteraction;

  Interaction({
    required this.id,
    required this.idProspect,
    required this.idCompte,
    this.idAssigne,
    required this.type,
    required this.note,
    this.suivi,
    required this.dateInteraction,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: (num.tryParse((json['id_interaction'] ?? 0).toString()) ?? 0).toInt(),
      idProspect: (num.tryParse((json['id_prospect'] ?? 0).toString()) ?? 0).toInt(),
      idCompte: (num.tryParse((json['id_compte'] ?? 0).toString()) ?? 0).toInt(),
      idAssigne: json['id_assigne'] != null ? (num.tryParse(json['id_assigne'].toString())?.toInt()) : null,
      type: json['type']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      suivi: json['suivi']?.toString(),
      dateInteraction: DateTime.parse(json['date_interaction'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_interaction': id,
        'id_prospect': idProspect,
        'id_compte': idCompte,
        'id_assigne': idAssigne,
        'type': type,
        'note': note,
        'suivi': suivi,
        'date_interaction': dateInteraction.toIso8601String(),
      };
}
