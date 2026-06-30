class Document {
  final int id;
  final int idProspect;
  final String name;
  final String filePath;
  final String mimeType;
  final int size;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.idProspect,
    required this.name,
    required this.filePath,
    required this.mimeType,
    required this.size,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id_document'] as int,
      idProspect: json['id_prospect'] as int,
      name: json['nom']?.toString() ?? '',
      filePath: json['chemin_fichier']?.toString() ?? '',
      mimeType: json['type_mime']?.toString() ?? '',
      size: json['taille'] as int? ?? 0,
      createdAt: DateTime.parse(json['creation'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_document': id,
        'id_prospect': idProspect,
        'nom': name,
        'chemin_fichier': filePath,
        'type_mime': mimeType,
        'taille': size,
        'creation': createdAt.toIso8601String(),
      };
}
