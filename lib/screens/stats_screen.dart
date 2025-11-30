import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/text_formatter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final authProvider = context.read<AuthProvider>();
    final statsProvider = context.read<StatsProvider>();
    if (authProvider.currentUser != null) {
      statsProvider.loadProspectStats(authProvider.currentUser!.id);
      statsProvider.loadConversionStats(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, _) {
          if (statsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Taux de conversion
                  if (statsProvider.conversionStats != null)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Taux de Conversion',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${statsProvider.conversionStats!.totalProspects}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Total Prospects'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${statsProvider.conversionStats!.convertedClients}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Convertis'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(statsProvider.conversionStats!.conversionRate * 100).toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Taux'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Distribution par statut - Graphique en camembert
                  Text(
                    'Distribution par Statut',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  if (statsProvider.prospectStats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucune donnée disponible'),
                    )
                  else
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieSections(statsProvider),
                                  centerSpaceRadius: 50,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Légende
                            Column(
                              children: statsProvider.prospectStats
                                  .map(
                                    (stat) => _buildLegendItem(
                                      context,
                                      stat.status,
                                      stat.count,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStats,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(StatsProvider statsProvider) {
    final colors = {
      'nouveau': Colors.blue,
      'interesse': Colors.amber,
      'negociation': Colors.orange,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    final total = statsProvider.prospectStats.fold<int>(
      0,
      (sum, stat) => sum + stat.count,
    );

    return statsProvider.prospectStats.map((stat) {
      final percentage = total > 0 ? (stat.count / total) * 100 : 0.0;
      final color = colors[stat.status] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: stat.count.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(BuildContext context, String status, int count) {
    final colors = {
      'nouveau': Colors.blue,
      'interesse': Colors.amber,
      'negociation': Colors.orange,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    final color = colors[status] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              TextFormatter.formatStatus(status),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
