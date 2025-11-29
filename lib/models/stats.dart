class ProspectStats {
  final String status;
  final int count;

  ProspectStats({required this.status, required this.count});

  factory ProspectStats.fromJson(Map<String, dynamic> json) {
    return ProspectStats(
      status: json['status'] as String,
      count: json['count'] as int,
    );
  }
}

class ConversionStats {
  final int totalProspects;
  final int convertedClients;
  final double conversionRate;

  ConversionStats({
    required this.totalProspects,
    required this.convertedClients,
    required this.conversionRate,
  });

  factory ConversionStats.fromJson(Map<String, dynamic> json) {
    return ConversionStats(
      totalProspects: json['total_prospects'] as int,
      convertedClients: json['converted_clients'] as int,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
    );
  }
}
