class Prospect {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final String type;
  final String status;
  final DateTime creation;
  final DateTime dateUpdate;
  final int assignation;

  Prospect({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.type,
    required this.status,
    required this.creation,
    required this.dateUpdate,
    required this.assignation,
  });

  factory Prospect.fromJson(Map<String, dynamic> json) {
    return Prospect(
      id: json['id_prospect'] as int,
      nom: json['nomp'] as String? ?? '',
      prenom: json['prenomp'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'nouveau',
      creation: DateTime.parse(json['creation'] as String),
      dateUpdate: DateTime.parse(json['date_update'] as String),
      assignation: json['assignation'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_prospect': id,
        'nomp': nom,
        'prenomp': prenom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'type': type,
        'status': status,
        'creation': creation.toIso8601String(),
        'date_update': dateUpdate.toIso8601String(),
        'assignation': assignation,
      };

  String get fullName => '$prenom $nom';
}
