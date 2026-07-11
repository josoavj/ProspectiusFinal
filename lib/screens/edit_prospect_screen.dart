import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../utils/text_formatter.dart';
import '../utils/app_snackbars.dart';

class EditProspectScreen extends StatefulWidget {
  final Prospect prospect;

  const EditProspectScreen({super.key, required this.prospect});

  @override
  State<EditProspectScreen> createState() => _EditProspectScreenState();
}

class _EditProspectScreenState extends State<EditProspectScreen> {
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
  late TextEditingController _consentementSourceController;

  late String _selectedType;
  late String _selectedStatus;
  late String _selectedPriorite;
  DateTime? _consentementDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.prospect;
    _nomController = TextEditingController(text: p.nom);
    _prenomController = TextEditingController(text: p.prenom);
    _emailController = TextEditingController(text: p.email);
    _telephoneController = TextEditingController(text: p.telephone);
    _adresseController = TextEditingController(text: p.adresse);
    _sourceController = TextEditingController(text: p.source ?? '');
    _nomEntrepriseController = TextEditingController(text: p.nomEntreprise ?? '');
    _posteController = TextEditingController(text: p.poste ?? '');
    _linkedinController = TextEditingController(text: p.linkedinUrl ?? '');
    _siteWebController = TextEditingController(text: p.siteWeb ?? '');
    _descriptionController = TextEditingController(text: p.description ?? '');
    _consentementSourceController = TextEditingController(text: p.consentementSource ?? '');

    _selectedType = p.type;
    _selectedStatus = p.status;
    _selectedPriorite = p.priorite;
    _consentementDate = p.consentementDate;
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
    _consentementSourceController.dispose();
    super.dispose();
}

  void _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

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
      'consentement_date': _consentementDate?.toIso8601String(),
      'consentement_source': _consentementSourceController.text,
      'userId': authProvider.currentUser!.id,
      'version': widget.prospect.version, // Ajout de la version pour le verrouillage
    };

    final success = await prospectProvider.updateProspect(
      authProvider.currentUser!.id,
      authProvider.currentUser!.typeCompte,
      widget.prospect.id,
      updateData,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final updatedProspect = Prospect(
        id: widget.prospect.id,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        adresse: _adresseController.text,
        type: _selectedType,
        status: _selectedStatus,
        priorite: _selectedPriorite,
        source: _sourceController.text,
        nomEntreprise: _nomEntrepriseController.text,
        poste: _posteController.text,
        linkedinUrl: _linkedinController.text,
        siteWeb: _siteWebController.text,
        description: _descriptionController.text,
        consentementDate: _consentementDate,
        consentementSource: _consentementSourceController.text,
        creation: widget.prospect.creation,
        dateUpdate: DateTime.now(),
        assignation: widget.prospect.assignation,
      );
      AppSnackBars.showSuccess(context, 'Prospect mis à jour');
      Navigator.pop(context, updatedProspect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le prospect')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSection(context, 'Informations Personnelles', [
                  _buildField(_nomController, 'Nom', Icons.person),
                  _buildField(_prenomController, 'Prénom', Icons.person_outline),
                  _buildField(_emailController, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                  _buildField(_telephoneController, 'Téléphone', Icons.phone_outlined, type: TextInputType.phone),
                  _buildField(_adresseController, 'Adresse', Icons.location_on_outlined),
                ]),
                const SizedBox(height: 16),
                _buildSection(context, 'Professionnel', [
                  _buildDropdown('Type', _selectedType, ['particulier', 'societe', 'organisation'], (val) => setState(() => _selectedType = val!), labelFormatter: TextFormatter.formatType),
                  if (_selectedType != 'particulier') ...[
                    _buildField(
                      _nomEntrepriseController, 
                      _selectedType == 'organisation' ? 'Organisation' : 'Entreprise',
                      _selectedType == 'organisation' ? Icons.account_balance : Icons.business
                    ),
                    _buildField(_posteController, 'Poste', Icons.work_outline),
                  ],
                  _buildDropdown('Priorité', _selectedPriorite, ['basse', 'moyenne', 'haute'], (val) => setState(() => _selectedPriorite = val!), labelFormatter: TextFormatter.formatPriority),
                  _buildDropdown('Statut', _selectedStatus, ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'], (val) => setState(() => _selectedStatus = val!), labelFormatter: TextFormatter.formatStatus),
                ]),
                const SizedBox(height: 16),
                _buildSection(context, 'Digital & Source', [
                  _buildField(_sourceController, 'Source', Icons.source),
                  _buildField(_siteWebController, 'Site Web', Icons.language, type: TextInputType.url),
                  _buildField(_linkedinController, 'URL LinkedIn', Icons.link, type: TextInputType.url),
                ]),
                const SizedBox(height: 16),
                _buildSection(context, 'Notes', [
                  _buildField(_descriptionController, 'Description / Contexte', Icons.note_outlined, maxLines: 5),
                ]),
                const SizedBox(height: 16),
                _buildSection(context, 'RGPD & Conformité', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Date du consentement', style: TextStyle(fontSize: 14)),
                    subtitle: Text(_consentementDate == null ? 'Non définie' : '${_consentementDate!.day}/${_consentementDate!.month}/${_consentementDate!.year}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _consentementDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _consentementDate = date);
                      },
                      child: const Text('Modifier'),
                    ),
                  ),
                  _buildField(_consentementSourceController, 'Source du consentement (ex: Formulaire web)', Icons.verified_user_outlined),
                ]),
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
                    child: const Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
