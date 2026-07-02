import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/prospect_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/text_formatter.dart';
import 'prospect_detail_screen.dart';

class ExplorationScreen extends StatefulWidget {
  const ExplorationScreen({super.key});

  @override
  State<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends State<ExplorationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'date_desc';
  List<Prospect> _filteredProspects = [];

  final List<String> _categories = ['Tous', 'Entreprise', 'Particulier', 'Organisation'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProspects);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProspects());
  }

  Future<void> _loadProspects() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();
    if (authProvider.currentUser != null) {
      await prospectProvider.loadProspects(
        authProvider.currentUser!.id,
        authProvider.currentUser!.typeCompte,
      );
      _filterProspects();
    }
  }

  void _filterProspects() {
    final prospectProvider = context.read<ProspectProvider>();
    final searchQuery = _searchController.text.toLowerCase();

    _filteredProspects = prospectProvider.prospects.where((prospect) {
      final matchesSearch = searchQuery.isEmpty ||
          prospect.fullName.toLowerCase().contains(searchQuery) ||
          prospect.email.toLowerCase().contains(searchQuery) ||
          prospect.telephone.contains(searchQuery);

      final matchesCategory = _selectedCategory == 'Tous' ||
          prospect.type.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesDate = (_startDate == null || prospect.creation.isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
          (_endDate == null || prospect.creation.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    switch (_sortBy) {
      case 'date_desc': _filteredProspects.sort((a, b) => b.creation.compareTo(a.creation)); break;
      case 'date_asc': _filteredProspects.sort((a, b) => a.creation.compareTo(b.creation)); break;
      case 'nom': _filteredProspects.sort((a, b) => a.fullName.compareTo(b.fullName)); break;
      case 'status': _filteredProspects.sort((a, b) => a.status.compareTo(b.status)); break;
    }
    if (mounted) setState(() {});
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explorez et filtrez vos prospects',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(colorScheme),
            const SizedBox(height: 20),
            _buildFiltersSection(colorScheme),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_filteredProspects.length} résultat(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_filteredProspects.length < context.read<ProspectProvider>().prospects.length)
                  TextButton(onPressed: _clearFilters, child: const Text('Tout afficher')),
              ],
            ),
            const SizedBox(height: 12),
            if (_filteredProspects.isEmpty) _buildEmptyState(colorScheme) else _buildProspectsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Recherche rapide...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty 
          ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _filterProspects(); }) 
          : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFiltersSection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((c) => ChoiceChip(
                label: Text(c),
                selected: _selectedCategory == c,
                onSelected: (val) { if (val) setState(() => _selectedCategory = c); _filterProspects(); },
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Trier par', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _buildSortDropdown(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(ColorScheme colorScheme) {
    return DropdownButton<String>(
      value: _sortBy,
      isExpanded: true,
      underline: Container(height: 1, color: colorScheme.outlineVariant),
      onChanged: (val) { if (val != null) setState(() => _sortBy = val); _filterProspects(); },
      items: const [
        DropdownMenuItem(value: 'date_desc', child: Text('Plus récents')),
        DropdownMenuItem(value: 'date_asc', child: Text('Plus anciens')),
        DropdownMenuItem(value: 'nom', child: Text('Nom (A-Z)')),
        DropdownMenuItem(value: 'status', child: Text('Statut')),
      ],
    );
  }

  Widget _buildProspectsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProspects.length,
      itemBuilder: (context, index) {
        final p = _filteredProspects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${TextFormatter.formatType(p.type)} • ${p.email}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProspectDetailScreen(prospect: p))),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('Aucun résultat', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
