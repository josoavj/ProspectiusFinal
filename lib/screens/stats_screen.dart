import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedStatus;

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
    return Scaffold(body: Consumer<StatsProvider>(
      builder: (context, statsProvider, _) {
        return SimpleStateBuilder(
            isLoading: statsProvider.isLoading,
            error: statsProvider.error,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Bouton d'actualisation en haut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _loadStats,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualiser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                    // Distribution par statut - Graphique en barres
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Graphique en barres avec layout amélioré
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Axe Y personnalisé à gauche
                                  SizedBox(
                                    width: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: _buildYAxisLabels(
                                        statsProvider,
                                      ),
                                    ),
                                  ),
                                  // Graphique
                                  Expanded(
                                    child: SizedBox(
                                      height: 300,
                                      child: BarChart(
                                        BarChartData(
                                          barGroups:
                                              _buildBarGroups(statsProvider),
                                          borderData: FlBorderData(show: false),
                                          gridData: const FlGridData(
                                            show: true,
                                            drawHorizontalLine: true,
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget:
                                                    _getTitlesForBarChart,
                                                reservedSize: 40,
                                              ),
                                            ),
                                            leftTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          maxY: _getMaxYForBarChart(
                                              statsProvider),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Détails cliquables
                              Text(
                                'Détails par statut',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildSelectableStatusDetails(
                                statsProvider,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Performances
                    Text(
                      'Performances',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    if (statsProvider.prospectStats.isNotEmpty)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildPerformanceMetric(
                                context,
                                'Taux de Conversion',
                                _calculateConversionRate(statsProvider),
                                Colors.green,
                              ),
                              const SizedBox(height: 16),
                              _buildPerformanceMetric(
                                context,
                                'Taux de Perte',
                                _calculateLossRate(statsProvider),
                                Colors.red,
                              ),
                              const SizedBox(height: 16),
                              _buildPerformanceMetric(
                                context,
                                'Taux d\'Engagement',
                                _calculateEngagementRate(statsProvider),
                                Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildPerformanceMetric(
                                context,
                                'Prospects en Attente',
                                _calculatePendingCount(statsProvider),
                                Colors.orange,
                                isCount: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ));
      },
    ));
  }

  Widget _buildPerformanceMetric(
    BuildContext context,
    String label,
    dynamic value,
    Color color, {
    bool isCount = false,
  }) {
    final displayValue =
        isCount ? value.toString() : '${value.toStringAsFixed(1)}%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateConversionRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats
        .fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final converted = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'converti',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    return statsProvider.prospectStats.any((stat) => stat.status == 'converti')
        ? (converted / total) * 100
        : 0;
  }

  double _calculateLossRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats
        .fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final lost = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'perdu',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    return statsProvider.prospectStats.any((stat) => stat.status == 'perdu')
        ? (lost / total) * 100
        : 0;
  }

  double _calculateEngagementRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats
        .fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final interested = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'interesse',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    final negotiating = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'negociation',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    final engaged = (statsProvider.prospectStats
                .any((stat) => stat.status == 'interesse')
            ? interested
            : 0) +
        (statsProvider.prospectStats.any((stat) => stat.status == 'negociation')
            ? negotiating
            : 0);
    return (engaged / total) * 100;
  }

  int _calculatePendingCount(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats
        .fold<int>(0, (sum, stat) => sum + stat.count);
    final converted = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'converti',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    final lost = statsProvider.prospectStats
        .firstWhere((stat) => stat.status == 'perdu',
            orElse: () => statsProvider.prospectStats.first)
        .count;
    final convertedCount =
        statsProvider.prospectStats.any((stat) => stat.status == 'converti')
            ? converted
            : 0;
    final lostCount =
        statsProvider.prospectStats.any((stat) => stat.status == 'perdu')
            ? lost
            : 0;
    return total - convertedCount - lostCount;
  }

  List<Widget> _buildYAxisLabels(StatsProvider statsProvider) {
    final maxY = _getMaxYForBarChart(statsProvider);
    final step = (maxY / 5).ceil();

    return List.generate(6, (index) {
      final value = step * (5 - index);
      return Text(
        value.toStringAsFixed(0),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      );
    });
  }

  List<BarChartGroupData> _buildBarGroups(StatsProvider statsProvider) {
    final colors = {
      'nouveau': Colors.blue,
      'interesse': Colors.amber,
      'negociation': Colors.orange,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    return List.generate(
      statsProvider.prospectStats.length,
      (index) {
        final stat = statsProvider.prospectStats[index];
        final color = colors[stat.status] ?? Colors.grey;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: stat.count.toDouble(),
              color: color,
              width: 30,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getTitlesForBarChart(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final provider = Provider.of<StatsProvider>(context, listen: false);
    final index = value.toInt();

    if (index >= 0 && index < provider.prospectStats.length) {
      final stat = provider.prospectStats[index];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          TextFormatter.formatStatus(stat.status),
          style: style,
        ),
      );
    }

    return const Text('');
  }

  double _getMaxYForBarChart(StatsProvider statsProvider) {
    if (statsProvider.prospectStats.isEmpty) return 10;
    final max = statsProvider.prospectStats
        .map((stat) => stat.count)
        .reduce((a, b) => a > b ? a : b);
    return (max * 1.2).toDouble();
  }

  Widget _buildSelectableStatusDetails(StatsProvider statsProvider) {
    final colors = {
      'nouveau': Colors.blue,
      'interesse': Colors.amber,
      'negociation': Colors.orange,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    final total = statsProvider.prospectStats
        .fold<int>(0, (sum, stat) => sum + stat.count);

    return Column(
      children: statsProvider.prospectStats.map((stat) {
        final color = colors[stat.status] ?? Colors.grey;
        final percentage =
            total > 0 ? ((stat.count / total) * 100).toStringAsFixed(1) : '0.0';
        final isSelected = _selectedStatus == stat.status;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? color.withValues(alpha: 0.05) : Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatus =
                      _selectedStatus == stat.status ? null : stat.status;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TextFormatter.formatStatus(stat.status),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                          if (isSelected)
                            Text(
                              'Pourcentage : $percentage%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        stat.count.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
