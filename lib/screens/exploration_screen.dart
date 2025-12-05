import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/prospect.dart';
import '../providers/prospect_provider.dart';
import '../providers/auth_provider.dart';
import 'prospect_detail_screen.dart';

class ExplorationScreen extends StatefulWidget {
  const ExplorationScreen({Key? key}) : super(key: key);

  @override
  State<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends State<ExplorationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'date_desc'; // date_desc, date_asc, nom, status
  List<Prospect> _filteredProspects = [];

  final List<String> _categories = [
    'Tous',
    'Entreprise',
    'Particulier',
    'Organisation',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProspects);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProspects();
    });
  }

  Future<void> _loadProspects() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    if (authProvider.currentUser != null) {
      await prospectProvider.loadProspects(authProvider.currentUser!.id);
      _filterProspects();
    }
  }

  void _filterProspects() {
    final prospectProvider = context.read<ProspectProvider>();
    final searchQuery = _searchController.text.toLowerCase();

    _filteredProspects = prospectProvider.prospects.where((prospect) {
      // Filtre par recherche
      final matchesSearch = searchQuery.isEmpty ||
          prospect.fullName.toLowerCase().contains(searchQuery) ||
          prospect.email.toLowerCase().contains(searchQuery) ||
          prospect.telephone.contains(searchQuery) ||
          prospect.adresse.toLowerCase().contains(searchQuery);

      // Filtre par catégorie
      final matchesCategory = _selectedCategory == 'Tous' ||
          prospect.type.toLowerCase() == _selectedCategory.toLowerCase();

      // Filtre par dates
      final matchesDate = (_startDate == null ||
              prospect.creation
                  .isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
          (_endDate == null ||
              prospect.creation
                  .isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    // Tri
    switch (_sortBy) {
      case 'date_desc':
        _filteredProspects.sort((a, b) => b.creation.compareTo(a.creation));
        break;
      case 'date_asc':
        _filteredProspects.sort((a, b) => a.creation.compareTo(b.creation));
        break;
      case 'nom':
        _filteredProspects.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'status':
        _filteredProspects.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'type':
        _filteredProspects.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    setState(() {});
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _filterProspects();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _filterProspects();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'Tous';
      _startDate = null;
      _endDate = null;
      _sortBy = 'date_desc';
    });
    _filterProspects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(),
              const SizedBox(height: 20),

              // Barre de recherche
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Filtres
              _buildFiltersSection(),
              const SizedBox(height: 20),

              // Résultats
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recherchez et explorez vos prospects avec des filtres avancés',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher par nom, email, téléphone ou adresse...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterProspects();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre filtres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres et tri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réinitialiser'),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Filtre par catégorie
            Text(
              'Catégorie',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildCategoryFilter(),
            const SizedBox(height: 16),

            // Filtres par dates
            Text(
              'Période de création',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildDateFilters(),
            const SizedBox(height: 16),

            // Tri
            Text(
              'Trier par',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildSortDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = category;
            });
            _filterProspects();
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.blue[100],
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateFilters() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectStartDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _startDate == null
                        ? 'Du'
                        : DateFormat('dd/MM/yyyy').format(_startDate!),
                    style: TextStyle(
                      color: _startDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _selectEndDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _endDate == null
                        ? 'Au'
                        : DateFormat('dd/MM/yyyy').format(_endDate!),
                    style: TextStyle(
                      color: _endDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _sortBy = newValue;
          });
          _filterProspects();
        }
      },
      items: const [
        DropdownMenuItem(
          value: 'date_desc',
          child: Text('Plus récents en premier'),
        ),
        DropdownMenuItem(
          value: 'date_asc',
          child: Text('Plus anciens en premier'),
        ),
        DropdownMenuItem(
          value: 'nom',
          child: Text('Alphabétique (A-Z)'),
        ),
        DropdownMenuItem(
          value: 'status',
          child: Text('Par statut'),
        ),
        DropdownMenuItem(
          value: 'type',
          child: Text('Par type'),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Infos résultats
        Text(
          '${_filteredProspects.length} résultat(s)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Liste des prospects
        if (_filteredProspects.isEmpty)
          _buildEmptyState()
        else
          _buildProspectsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun prospect trouvé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres ou votre recherche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProspectsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProspects.length,
      itemBuilder: (context, index) {
        final prospect = _filteredProspects[index];
        return _buildProspectCard(prospect);
      },
    );
  }

  Widget _buildProspectCard(Prospect prospect) {
    return GestureDetector(
      onTap: () => _showProspectDetailsDialog(prospect),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prospect.fullName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prospect.type,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(prospect.status),
                ],
              ),
              const SizedBox(height: 12),

              // Informations de contact
              _buildContactInfo(prospect),
              const SizedBox(height: 12),

              // Adresse et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prospect.adresse,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date de création
              Text(
                'Créé le ${DateFormat('dd/MM/yyyy').format(prospect.creation)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(Prospect prospect) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prospect.email,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prospect.telephone,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'nouveau': Colors.blue,
      'en_cours': Colors.orange,
      'qualifié': Colors.purple,
      'converti': Colors.green,
      'perdu': Colors.red,
    };

    final statusLabels = {
      'nouveau': 'Nouveau',
      'en_cours': 'En cours',
      'qualifié': 'Qualifié',
      'converti': 'Converti',
      'perdu': 'Perdu',
    };

    final color = statusColors[status] ?? Colors.grey;
    final label = statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showProspectDetailsDialog(Prospect prospect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête avec nom et bouton fermer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prospect.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prospect.type,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Statut
                  _buildDetailRow(
                    icon: Icons.flag,
                    label: 'Statut',
                    value: prospect.status,
                    badge: _buildStatusBadge(prospect.status),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildDetailRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: prospect.email,
                  ),
                  const SizedBox(height: 16),

                  // Téléphone
                  _buildDetailRow(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: prospect.telephone,
                  ),
                  const SizedBox(height: 16),

                  // Adresse
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Adresse',
                    value: prospect.adresse,
                  ),
                  const SizedBox(height: 16),

                  // Date de création
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Créé le',
                    value: DateFormat('dd/MM/yyyy - HH:mm')
                        .format(prospect.creation),
                  ),
                  const SizedBox(height: 16),

                  // Dernière modification
                  _buildDetailRow(
                    icon: Icons.update,
                    label: 'Dernière mise à jour',
                    value: DateFormat('dd/MM/yyyy - HH:mm')
                        .format(prospect.dateUpdate),
                  ),
                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProspectDetailScreen(
                                  prospect: prospect,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Voir détails'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? badge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              if (badge != null)
                badge
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
