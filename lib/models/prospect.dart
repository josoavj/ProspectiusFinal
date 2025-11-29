class Prospect {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String entreprise;
  final String poste;
  final String statut;
  final String source;
  final String notes;
  final int idUtilisateur;
  final DateTime dateCreation;
  final DateTime? dateModification;

  Prospect({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.entreprise,
    required this.poste,
    required this.statut,
    required this.source,
    required this.notes,
    required this.idUtilisateur,
    required this.dateCreation,
    this.dateModification,
  });

  factory Prospect.fromJson(Map<String, dynamic> json) {
    return Prospect(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String? ?? '',
      entreprise: json['entreprise'] as String? ?? '',
      poste: json['poste'] as String? ?? '',
      statut: json['statut'] as String? ?? 'En cours',
      source: json['source'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      idUtilisateur: json['id_utilisateur'] as int,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: json['date_modification'] != null
          ? DateTime.parse(json['date_modification'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'telephone': telephone,
    'entreprise': entreprise,
    'poste': poste,
    'statut': statut,
    'source': source,
    'notes': notes,
    'id_utilisateur': idUtilisateur,
    'date_creation': dateCreation.toIso8601String(),
    'date_modification': dateModification?.toIso8601String(),
  };

  String get fullName => '$prenom $nom';
}
