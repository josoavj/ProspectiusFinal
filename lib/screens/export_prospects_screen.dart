import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/prospect_provider.dart';
import '../services/excel_service.dart';
import '../services/export_logging_service.dart';
import '../utils/text_formatter.dart';

class ExportProspectsScreen extends StatefulWidget {
  const ExportProspectsScreen({Key? key}) : super(key: key);

  @override
  State<ExportProspectsScreen> createState() => _ExportProspectsScreenState();
}

class _ExportProspectsScreenState extends State<ExportProspectsScreen> {
  final _fileNameController = TextEditingController(
    text: 'prospects_${DateTime.now().toString().split(' ')[0]}',
  );

  String _exportType = 'all'; // 'all', 'status', 'type'
  String? _selectedStatus;
  String? _selectedType;
  bool _isExporting = false;
  String? _successMessage;
  String? _errorMessage;

  final _statuses = [
    'nouveau',
    'interesse',
    'negociation',
    'converti',
    'perdu'
  ];
  final _types = ['particulier', 'societe', 'organisation'];

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _handleExport() async {
    setState(() {
      _isExporting = true;
      _successMessage = null;
      _errorMessage = null;
    });

    final exportLogging = ExportLoggingService();
    final startTime = DateTime.now();

    try {
      final prospectProvider = context.read<ProspectProvider>();
      final excelService = ExcelService();

      // Demander à l'utilisateur de choisir le répertoire
      final selectedDirectory = await excelService.pickExportDirectory();

      exportLogging.logDirectorySelection(
        selectedDirectory,
        selectedDirectory != null,
        selectedDirectory == null ? 'Utilisateur a annulé la sélection' : null,
      );

      if (selectedDirectory == null) {
        setState(() {
          _errorMessage = 'Aucun répertoire sélectionné';
          _isExporting = false;
        });
        return;
      }

      List<Prospect> prospectsToExport = [];

      // Filtrer les prospects selon les critères sélectionnés
      if (_exportType == 'all') {
        prospectsToExport = prospectProvider.prospects;
      } else if (_exportType == 'status' && _selectedStatus != null) {
        prospectsToExport = prospectProvider.prospects
            .where((p) => p.status == _selectedStatus)
            .toList();
      } else if (_exportType == 'type' && _selectedType != null) {
        prospectsToExport = prospectProvider.prospects
            .where((p) => p.type == _selectedType)
            .toList();
      }

      if (prospectsToExport.isEmpty) {
        setState(() {
          _errorMessage = 'Aucun prospect à exporter avec ces critères';
          _isExporting = false;
        });
        return;
      }

      exportLogging.logExportStart(
        _fileNameController.text,
        selectedDirectory,
        prospectsToExport.length,
      );

      // Exporter vers Excel dans le répertoire sélectionné
      final filePath = await excelService.exportProspectsToExcel(
        prospectsToExport,
        fileName: _fileNameController.text,
        directoryPath: selectedDirectory,
      );

      final duration = DateTime.now().difference(startTime);
      exportLogging.logExportSuccess(
        filePath,
        prospectsToExport.length,
        duration,
      );

      setState(() {
        _successMessage =
            'Fichier créé avec succès:\n${_fileNameController.text}.xlsx\n\nEmplacement:\n$filePath';
      });
    } catch (e) {
      final stage = 'export_prospects';
      exportLogging.logExportError(stage, e.toString(), null);
      setState(() {
        _errorMessage = 'Erreur lors de l\'export: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exporter les prospects'),
        elevation: 0,
      ),
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affichage du nombre de prospects
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${prospectProvider.prospects.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Total prospects'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Type d'export
                  Text(
                    'Type d\'export',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('Tous'),
                      ),
                      ButtonSegment(
                        value: 'status',
                        label: Text('Par statut'),
                      ),
                      ButtonSegment(
                        value: 'type',
                        label: Text('Par type'),
                      ),
                    ],
                    selected: {_exportType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _exportType = newSelection.first;
                        _selectedStatus = null;
                        _selectedType = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Filtres conditionnels
                  if (_exportType == 'status') ...[
                    Text(
                      'Sélectionner le statut',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                      items: _statuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(TextFormatter.formatStatus(status)),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else if (_exportType == 'type') ...[
                    Text(
                      'Sélectionner le type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      items: _types
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(TextFormatter.formatType(type)),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Nom du fichier
                  Text(
                    'Nom du fichier',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du fichier (sans .xlsx)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: '.xlsx',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Messages de statut
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Export réussi',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Bouton d'export
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _handleExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        _isExporting ? 'Export en cours...' : 'Exporter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
