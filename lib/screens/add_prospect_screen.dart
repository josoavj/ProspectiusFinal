import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../utils/text_formatter.dart';

class AddProspectScreen extends StatefulWidget {
  final Prospect? prospect;

  const AddProspectScreen({super.key, this.prospect});

  @override
  State<AddProspectScreen> createState() => _AddProspectScreenState();
}

class _AddProspectScreenState extends State<AddProspectScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _sourceController;
  late TextEditingController _nomEntrepriseController;
  late TextEditingController _posteController;
  late TextEditingController _linkedinController;
  late TextEditingController _siteWebController;
  late TextEditingController _descriptionController;
  late TextEditingController _interactionNoteController;

  String _selectedType = 'particulier';
  String _selectedStatus = 'nouveau';
  String _selectedPriorite = 'moyenne';
  String _selectedInteractionType = 'appel';

  @override
  void initState() {
    super.initState();
    final p = widget.prospect;
    _nomController = TextEditingController(text: p?.nom ?? '');
    _prenomController = TextEditingController(text: p?.prenom ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _telephoneController = TextEditingController(text: p?.telephone ?? '');
    _adresseController = TextEditingController(text: p?.adresse ?? '');
    _sourceController = TextEditingController(text: p?.source ?? '');
    _nomEntrepriseController = TextEditingController(text: p?.nomEntreprise ?? '');
    _posteController = TextEditingController(text: p?.poste ?? '');
    _linkedinController = TextEditingController(text: p?.linkedinUrl ?? '');
    _siteWebController = TextEditingController(text: p?.siteWeb ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _interactionNoteController = TextEditingController();

    _selectedType = p?.type ?? 'particulier';
    _selectedStatus = p?.status ?? 'nouveau';
    _selectedPriorite = p?.priorite ?? 'moyenne';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _sourceController.dispose();
    _nomEntrepriseController.dispose();
    _posteController.dispose();
    _linkedinController.dispose();
    _siteWebController.dispose();
    _descriptionController.dispose();
    _interactionNoteController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.prospect != null ? 'Confirmer la modification' : 'Créer le prospect'),
        content: const Text('Êtes-vous sûr de vouloir continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06CE70), foregroundColor: Colors.white),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    final data = {
      'userId': authProvider.currentUser!.id,
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'email': _emailController.text,
      'telephone': _telephoneController.text,
      'adresse': _adresseController.text,
      'type': _selectedType,
      'status': _selectedStatus,
      'priorite': _selectedPriorite,
      'source': _sourceController.text,
      'nomEntreprise': _nomEntrepriseController.text,
      'poste': _posteController.text,
      'linkedinUrl': _linkedinController.text,
      'siteWeb': _siteWebController.text,
      'description': _descriptionController.text,
    };

    bool success;
    if (widget.prospect != null) {
      final updateData = {
        'nomp': _nomController.text,
        'prenomp': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'adresse': _adresseController.text,
        'type': _selectedType,
        'status': _selectedStatus,
        'priorite': _selectedPriorite,
        'source': _sourceController.text,
        'nom_entreprise': _nomEntrepriseController.text,
        'poste': _posteController.text,
        'linkedin_url': _linkedinController.text,
        'site_web': _siteWebController.text,
        'description': _descriptionController.text,
      };
      success = await prospectProvider.updateProspect(
        authProvider.currentUser!.id,
        authProvider.currentUser!.typeCompte,
        widget.prospect!.id,
        updateData,
      );
    } else {
      success = await prospectProvider.createProspect(
        data,
        authProvider.currentUser!.typeCompte,
      );
      if (success && _interactionNoteController.text.isNotEmpty) {
        final created = prospectProvider.prospects.firstWhere(
          (p) => p.nom == _nomController.text && p.prenom == _prenomController.text,
          orElse: () => widget.prospect ?? Prospect(id: -1, nom: '', prenom: '', email: '', telephone: '', adresse: '', type: '', status: '', creation: DateTime.now(), dateUpdate: DateTime.now(), assignation: 0)
        );
        if (created.id != -1) {
          await prospectProvider.createInteraction(created.id, authProvider.currentUser!.id, _selectedInteractionType, _interactionNoteController.text, DateTime.now());
        }
      }
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.prospect != null ? 'Prospect mis à jour' : 'Prospect créé')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.prospect != null ? 'Éditer prospect' : 'Nouveau prospect')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(context, 'Informations Personnelles', [
              _buildField(_prenomController, 'Prénom', Icons.person_outline),
              _buildField(_nomController, 'Nom', Icons.person),
              _buildField(_emailController, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
              _buildField(_telephoneController, 'Téléphone', Icons.phone_outlined, type: TextInputType.phone),
              _buildField(_adresseController, 'Adresse', Icons.location_on_outlined),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Professionnel', [
              _buildDropdown('Type', _selectedType, ['particulier', 'societe', 'organisation'], (val) => setState(() => _selectedType = val!), labelFormatter: TextFormatter.formatType),
              if (_selectedType != 'particulier') ...[
                _buildField(_nomEntrepriseController, 'Entreprise', Icons.business),
                _buildField(_posteController, 'Poste', Icons.work_outline),
              ],
              _buildDropdown('Priorité', _selectedPriorite, ['basse', 'moyenne', 'haute'], (val) => setState(() => _selectedPriorite = val!), labelFormatter: TextFormatter.formatPriority),
              _buildDropdown('Statut', _selectedStatus, ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'], (val) => setState(() => _selectedStatus = val!), labelFormatter: TextFormatter.formatStatus),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Digital & Source', [
              _buildField(_sourceController, 'Source (ex: LinkedIn, Salon...)', Icons.source),
              _buildField(_siteWebController, 'Site Web', Icons.language, type: TextInputType.url),
              _buildField(_linkedinController, 'URL LinkedIn', Icons.link, type: TextInputType.url),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Notes', [
              _buildField(_descriptionController, 'Description / Contexte', Icons.note_outlined, maxLines: 3),
            ]),
            if (widget.prospect == null) ...[
              const SizedBox(height: 16),
              _buildSection(context, 'Interaction Initiale', [
                _buildDropdown('Type d\'échange', _selectedInteractionType, ['appel', 'email', 'reunion', 'message', 'autre'], (val) => setState(() => _selectedInteractionType = val!), labelFormatter: TextFormatter.formatInteractionType),
                _buildField(_interactionNoteController, 'Note de l\'échange', Icons.chat_bubble_outline, maxLines: 2),
              ]),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, 
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.prospect != null ? 'Enregistrer les modifications' : 'Créer le prospect', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.primary)),
            const SizedBox(height: 16),
            ...children.expand((w) => [w, const SizedBox(height: 12)]).toList()..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged, {String Function(String)? labelFormatter}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((e) => DropdownMenuItem(
        value: e, 
        child: Text(labelFormatter != null ? labelFormatter(e) : e),
      )).toList(),
    );
  }
}
