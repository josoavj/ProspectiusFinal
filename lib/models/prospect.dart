class Prospect {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final String type;
  final String status;
  final String priorite;
  final String? source;
  final String? nomEntreprise;
  final String? poste;
  final String? linkedinUrl;
  final String? siteWeb;
  final String? description;
  final DateTime? consentementDate;
  final String? consentementSource;
  final DateTime creation;
  final DateTime dateUpdate;
  final int assignation;
  final int version;

  Prospect({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.type,
    required this.status,
    this.priorite = 'moyenne',
    this.source,
    this.nomEntreprise,
    this.poste,
    this.linkedinUrl,
    this.siteWeb,
    this.description,
    this.consentementDate,
    this.consentementSource,
    required this.creation,
    required this.dateUpdate,
    required this.assignation,
    this.version = 1,
  });

  factory Prospect.fromJson(Map<String, dynamic> json) {
    return Prospect(
      id: (num.tryParse((json['id_prospect'] ?? 0).toString()) ?? 0).toInt(),
      nom: json['nomp']?.toString() ?? '',
      prenom: json['prenomp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      type: json['type']?.toString() ?? 'particulier',
      status: json['status']?.toString() ?? 'interesse',
      priorite: json['priorite']?.toString() ?? 'moyenne',
      source: json['source']?.toString(),
      nomEntreprise: json['nom_entreprise']?.toString(),
      poste: json['poste']?.toString(),
      linkedinUrl: json['linkedin_url']?.toString(),
      siteWeb: json['site_web']?.toString(),
      description: json['description']?.toString(),
      consentementDate: json['consentement_date'] != null ? DateTime.parse(json['consentement_date'].toString()) : null,
      consentementSource: json['consentement_source']?.toString(),
      creation: DateTime.parse(json['creation'].toString()),
      dateUpdate: DateTime.parse(json['date_update'].toString()),
      assignation: (num.tryParse((json['assignation'] ?? 0).toString()) ?? 0).toInt(),
      version: (num.tryParse((json['version'] ?? 1).toString()) ?? 1).toInt(),
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
        'priorite': priorite,
        'source': source,
        'nom_entreprise': nomEntreprise,
        'poste': poste,
        'linkedin_url': linkedinUrl,
        'site_web': siteWeb,
        'description': description,
        'consentement_date': consentementDate?.toIso8601String(),
        'consentement_source': consentementSource,
        'creation': creation.toIso8601String(),
        'date_update': dateUpdate.toIso8601String(),
        'assignation': assignation,
        'version': version,
      };

  String get fullName => '$nom $prenom';
}
