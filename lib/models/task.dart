class Task {
  final int id;
  final int idProspect;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.idProspect,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id_tache'] as int,
      idProspect: json['id_prospect'] as int,
      title: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['date_echeance'] as String),
      isCompleted: (json['est_complete'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['creation'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_tache': id,
        'id_prospect': idProspect,
        'titre': title,
        'description': description,
        'date_echeance': dueDate.toIso8601String(),
        'est_complete': isCompleted ? 1 : 0,
        'creation': createdAt.toIso8601String(),
      };

  Task copyWith({
    int? id,
    int? idProspect,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      idProspect: idProspect ?? this.idProspect,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
