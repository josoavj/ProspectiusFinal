class StatusHistory {
  final int id;
  final int idProspect;
  final String? oldStatus;
  final String newStatus;
  final int changedBy;
  final DateTime changedAt;

  StatusHistory({
    required this.id,
    required this.idProspect,
    required this.oldStatus,
    required this.newStatus,
    required this.changedBy,
    required this.changedAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id_status_history'] as int,
      idProspect: json['id_prospect'] as int,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String? ?? '',
      changedBy: json['changed_by'] as int,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_status_history': id,
        'id_prospect': idProspect,
        'old_status': oldStatus,
        'new_status': newStatus,
        'changed_by': changedBy,
        'changed_at': changedAt.toIso8601String(),
      };
}
