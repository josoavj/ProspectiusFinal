import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stats.dart';
import '../providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/data_state_widget.dart';
import '../utils/text_formatter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  void _loadStats() {
    final authProvider = context.read<AuthProvider>();
    final statsProvider = context.read<StatsProvider>();
    if (authProvider.currentUser != null) {
      statsProvider.loadAllStats(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, _) {
          return SimpleStateBuilder(
            isLoading: statsProvider.isLoading,
            error: statsProvider.error,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildConversionCard(statsProvider),
                  const SizedBox(height: 32),
                  _buildDistributionSection(statsProvider),
                  const SizedBox(height: 32),
                  _buildPerformanceSection(statsProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Statistiques Globales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton.filledTonal(
          onPressed: _loadStats,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildConversionCard(StatsProvider statsProvider) {
    if (statsProvider.conversionStats == null) return const SizedBox.shrink();
    final stats = statsProvider.conversionStats!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Taux de Conversion Client', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Prospects', stats.totalProspects.toString(), Colors.blue),
                _buildStatItem('Clients', stats.convertedClients.toString(), Colors.green),
                _buildStatItem('Taux', '${(stats.conversionRate * 100).toStringAsFixed(1)}%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildDistributionSection(StatsProvider statsProvider) {
    if (statsProvider.prospectStats.isEmpty) return const SizedBox.shrink();
    
    final total = statsProvider.prospectStats.fold<int>(0, (sum, item) => sum + item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distribution par Statut', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                if (_touchedIndex != -1) {
                                  _selectedStatus = statsProvider.prospectStats[_touchedIndex].status;
                                }
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: _buildPieSections(statsProvider),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(total.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('TOTAL', style: TextStyle(fontSize: 12, color: Colors.grey[600], letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSelectableStatusDetails(statsProvider, total),
              ],
            ),
          ),
        ),
      ],
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

    return List.generate(statsProvider.prospectStats.length, (i) {
      final isTouched = i == _touchedIndex;
      final stat = statsProvider.prospectStats[i];
      final color = colors[stat.status] ?? Colors.grey;
      
      return PieChartSectionData(
        color: color,
        value: stat.count.toDouble(),
        title: isTouched ? '${stat.count}' : '',
        radius: isTouched ? 30 : 25,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Widget _buildSelectableStatusDetails(StatsProvider statsProvider, int total) {
    final colors = {
      'nouveau': Colors.blue,
      'interesse': Colors.amber,
      'negociation': Colors.orange,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    return Column(
      children: statsProvider.prospectStats.map((stat) {
        final color = colors[stat.status] ?? Colors.grey;
        final isSelected = _selectedStatus == stat.status;
        final percent = total > 0 ? (stat.count / total * 100).toStringAsFixed(1) : '0';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(TextFormatter.formatStatus(stat.status), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
              Text('$percent%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(width: 16),
              Text(stat.count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceSection(StatsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performances Clés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPerformanceMetric('Efficacité de Conversion', _calculateConversionRate(statsProvider), Colors.green),
        const SizedBox(height: 12),
        _buildPerformanceMetric('Engagement Prospects', _calculateEngagementRate(statsProvider), Colors.blue),
        const SizedBox(height: 12),
        _buildPerformanceMetric('Taux de Perte', _calculateLossRate(statsProvider), Colors.red),
      ],
    );
  }

  Widget _buildPerformanceMetric(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('${value.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  double _calculateConversionRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats.fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final converted = statsProvider.prospectStats.firstWhere((s) => s.status == 'converti', orElse: () => ProspectStats(status: '', count: 0)).count;
    return (converted / total) * 100;
  }

  double _calculateLossRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats.fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final lost = statsProvider.prospectStats.firstWhere((s) => s.status == 'perdu', orElse: () => ProspectStats(status: '', count: 0)).count;
    return (lost / total) * 100;
  }

  double _calculateEngagementRate(StatsProvider statsProvider) {
    final total = statsProvider.prospectStats.fold<int>(0, (sum, stat) => sum + stat.count);
    if (total == 0) return 0;
    final engaged = statsProvider.prospectStats.where((s) => s.status == 'interesse' || s.status == 'negociation').fold<int>(0, (sum, s) => sum + s.count);
    return (engaged / total) * 100;
  }
}
