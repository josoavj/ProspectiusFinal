class Account {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String username;
  final String typeCompte;
  final DateTime dateCreation;

  Account({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.username,
    required this.typeCompte,
    required this.dateCreation,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: (num.tryParse((json['id_compte'] ?? json['id'] ?? 0).toString()) ?? 0).toInt(),
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      typeCompte: (json['type_compte'] ?? json['typeCompte'])?.toString() ?? 'Utilisateur',
      dateCreation: DateTime.parse((json['date_creation'] ?? json['dateCreation'] ?? DateTime.now().toIso8601String()).toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'username': username,
    'type_compte': typeCompte,
    'date_creation': dateCreation.toIso8601String(),
  };

  String get fullName => '$prenom $nom';
}
