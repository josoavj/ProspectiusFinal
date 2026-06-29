import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';

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

  late String _selectedType;
  late String _selectedStatus;
  late String _selectedPriorite;
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

    _selectedType = p.type;
    _selectedStatus = p.status;
    _selectedPriorite = p.priorite;
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
    };

    final success = await prospectProvider.updateProspect(authProvider.currentUser!.id, widget.prospect.id, updateData);

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
        creation: widget.prospect.creation,
        dateUpdate: DateTime.now(),
        assignation: widget.prospect.assignation,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prospect mis à jour')));
      Navigator.pop(context, updatedProspect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le prospect')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSection('Informations Personnelles', [
                  _buildField(_prenomController, 'Prénom', Icons.person_outline),
                  _buildField(_nomController, 'Nom', Icons.person),
                  _buildField(_emailController, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                  _buildField(_telephoneController, 'Téléphone', Icons.phone_outlined, type: TextInputType.phone),
                  _buildField(_adresseController, 'Adresse', Icons.location_on_outlined),
                ]),
                const SizedBox(height: 16),
                _buildSection('Professionnel', [
                  _buildDropdown('Type', _selectedType, ['particulier', 'societe', 'organisation'], (val) => setState(() => _selectedType = val!)),
                  if (_selectedType != 'particulier') ...[
                    _buildField(_nomEntrepriseController, 'Entreprise', Icons.business),
                    _buildField(_posteController, 'Poste', Icons.work_outline),
                  ],
                  _buildDropdown('Priorité', _selectedPriorite, ['basse', 'moyenne', 'haute'], (val) => setState(() => _selectedPriorite = val!)),
                  _buildDropdown('Statut', _selectedStatus, ['nouveau', 'interesse', 'negociation', 'converti', 'perdu'], (val) => setState(() => _selectedStatus = val!)),
                ]),
                const SizedBox(height: 16),
                _buildSection('Digital & Source', [
                  _buildField(_sourceController, 'Source', Icons.source),
                  _buildField(_siteWebController, 'Site Web', Icons.language, type: TextInputType.url),
                  _buildField(_linkedinController, 'URL LinkedIn', Icons.link, type: TextInputType.url),
                ]),
                const SizedBox(height: 16),
                _buildSection('Notes', [
                  _buildField(_descriptionController, 'Description / Contexte', Icons.note_outlined, maxLines: 5),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                    child: const Text('Enregistrer les modifications', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
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

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    );
  }
}
