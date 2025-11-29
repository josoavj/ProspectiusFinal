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
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      typeCompte: json['type_compte'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
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
