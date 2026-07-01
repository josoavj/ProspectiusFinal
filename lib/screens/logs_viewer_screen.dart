import 'package:flutter/material.dart';
import '../services/logging_service.dart';
import '../utils/app_logger.dart';

class LogsViewerScreen extends StatefulWidget {
  final String title;
  const LogsViewerScreen({super.key, this.title = 'Logs'});

  @override
  State<LogsViewerScreen> createState() => _LogsViewerScreenState();
}

class _LogsViewerScreenState extends State<LogsViewerScreen> {
  late final LoggingService _loggingService;
  String _selectedTab = 'all'; // 'all', 'exports', 'errors'
  String _logs = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loggingService = LoggingService();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      String logs = '';
      if (_selectedTab == 'all') {
        logs = await _loadAllLogs();
      } else if (_selectedTab == 'exports') {
        logs = await _loggingService.getExportLogsSummary();
      } else if (_selectedTab == 'errors') {
        final errors = await _loggingService.findExportErrors();
        logs = errors.isEmpty ? 'Aucune erreur d\'export trouvée' : errors.join('\n\n');
      }
      if (mounted) setState(() => _logs = logs);
    } catch (e) {
      if (mounted) setState(() => _logs = 'Erreur: $e');
      AppLogger.error('Erreur chargement logs', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _loadAllLogs() async {
    try {
      final logFiles = await _loggingService.getLogFiles();
      final buffer = StringBuffer();
      buffer.writeln('RECAPITULATIF DES LOGS\n');
      for (final logFile in logFiles.reversed) {
        final fileName = logFile.path.split('/').last;
        buffer.writeln('Date: $fileName\n${'-' * 40}');
        try {
          final content = await _loggingService.readLogFileWithFallback(logFile);
          final lines = content.split('\n');
          final recentLines = lines.length > 50 ? lines.sublist(lines.length - 50) : lines;
          for (final line in recentLines) {
            if (line.isNotEmpty) buffer.writeln(line);
          }
        } catch (e) {
          buffer.writeln('[ERREUR] Lecture impossible: $e');
        }
        buffer.writeln('');
      }
      return buffer.toString();
    } catch (e) { return 'Erreur lecture: $e'; }
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les logs'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await _loggingService.cleanOldLogs(daysToKeep: 0);
              if (!mounted) return;
              Navigator.pop(context);
              _loadLogs();
            },
            child: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journaux système'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _loadLogs),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearLogs),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Tous'), icon: Icon(Icons.list)),
                ButtonSegment(value: 'exports', label: Text('Exports'), icon: Icon(Icons.import_export)),
                ButtonSegment(value: 'errors', label: Text('Erreurs'), icon: Icon(Icons.error_outline)),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (val) { setState(() => _selectedTab = val.first); _loadLogs(); },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _logs,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: isDark ? Colors.greenAccent[100] : Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
