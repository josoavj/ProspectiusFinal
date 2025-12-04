import 'package:flutter/material.dart';
import '../services/logging_service.dart';
import '../utils/app_logger.dart';

class LogsViewerScreen extends StatefulWidget {
  final String title;
  const LogsViewerScreen({Key? key, this.title = 'Logs'}) : super(key: key);

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
    setState(() {
      _isLoading = true;
    });

    try {
      String logs = '';

      if (_selectedTab == 'all') {
        logs = await _loadAllLogs();
      } else if (_selectedTab == 'exports') {
        logs = await _loggingService.getExportLogsSummary();
      } else if (_selectedTab == 'errors') {
        final errors = await _loggingService.findExportErrors();
        logs = errors.isEmpty
            ? 'Aucune erreur d\'export trouvée'
            : errors.join('\n\n');
      }

      setState(() {
        _logs = logs;
      });
    } catch (e) {
      setState(() {
        _logs = 'Erreur lors du chargement des logs: $e';
      });
      AppLogger.error('Erreur chargement logs', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _loadAllLogs() async {
    try {
      final logFiles = await _loggingService.getLogFiles();
      final buffer = StringBuffer();

      buffer.writeln('📋 TOUS LES LOGS');
      buffer.writeln('=' * 60);
      buffer.writeln('Fichiers de log trouvés: ${logFiles.length}\n');

      for (final logFile in logFiles.reversed) {
        final fileName = logFile.path.split('/').last;
        buffer.writeln('📅 $fileName');
        buffer.writeln('-' * 60);

        final content = await logFile.readAsString();
        final lines = content.split('\n');

        // Afficher les 50 dernières lignes
        final recentLines =
            lines.length > 50 ? lines.sublist(lines.length - 50) : lines;

        for (final line in recentLines) {
          if (line.isNotEmpty) {
            buffer.writeln(line);
          }
        }
        buffer.writeln('');
      }

      return buffer.toString();
    } catch (e) {
      return 'Erreur lecture des logs: $e';
    }
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer les logs'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer tous les fichiers de log? Cette action ne peut pas être annulée.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _loggingService.cleanOldLogs(daysToKeep: 0);
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {
                      _logs = 'Tous les logs ont été supprimés';
                    });
                  }
                } catch (e) {
                  AppLogger.error('Erreur suppression logs', e);
                }
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _exportLogsToFile() async {
    try {
      final logFiles = await _loggingService.getLogFiles();
      if (logFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun log à exporter')),
        );
        return;
      }

      final exportPath = await _loggingService.exportLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logs exportés vers: $exportPath')),
        );
      }
    } catch (e) {
      AppLogger.error('Erreur export logs', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadLogs,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportLogsToFile,
            tooltip: 'Exporter',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets de filtrage
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'all',
                        label: Text('Tous'),
                      ),
                      ButtonSegment<String>(
                        value: 'exports',
                        label: Text('Exports'),
                      ),
                      ButtonSegment<String>(
                        value: 'errors',
                        label: Text('Erreurs'),
                      ),
                    ],
                    selected: <String>{_selectedTab},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedTab = newSelection.first;
                      });
                      _loadLogs();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Zone d'affichage des logs
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[900],
                      child: SelectableText(
                        _logs,
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 11,
                          color: Colors.greenAccent,
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
