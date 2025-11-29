import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';

class AddProspectScreen extends StatefulWidget {
  final Prospect? prospect;

  const AddProspectScreen({Key? key, this.prospect}) : super(key: key);

  @override
  State<AddProspectScreen> createState() => _AddProspectScreenState();
}

class _AddProspectScreenState extends State<AddProspectScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _entrepriseController;
  late TextEditingController _posteController;
  late TextEditingController _sourceController;
  late TextEditingController _notesController;
  String _selectedStatut = 'En cours';

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.prospect?.nom ?? '');
    _prenomController = TextEditingController(
      text: widget.prospect?.prenom ?? '',
    );
    _emailController = TextEditingController(
      text: widget.prospect?.email ?? '',
    );
    _telephoneController = TextEditingController(
      text: widget.prospect?.telephone ?? '',
    );
    _entrepriseController = TextEditingController(
      text: widget.prospect?.entreprise ?? '',
    );
    _posteController = TextEditingController(
      text: widget.prospect?.poste ?? '',
    );
    _sourceController = TextEditingController(
      text: widget.prospect?.source ?? '',
    );
    _notesController = TextEditingController(
      text: widget.prospect?.notes ?? '',
    );
    _selectedStatut = widget.prospect?.statut ?? 'En cours';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _entrepriseController.dispose();
    _posteController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    if (widget.prospect != null) {
      await prospectProvider
          .updateProspect(authProvider.currentUser!.id, widget.prospect!.id, {
            'nom': _nomController.text,
            'prenom': _prenomController.text,
            'email': _emailController.text,
            'telephone': _telephoneController.text,
            'entreprise': _entrepriseController.text,
            'poste': _posteController.text,
            'statut': _selectedStatut,
            'source': _sourceController.text,
            'notes': _notesController.text,
          });
    } else {
      await prospectProvider.createProspect(
        authProvider.currentUser!.id,
        _nomController.text,
        _prenomController.text,
        _emailController.text,
        _telephoneController.text,
        _entrepriseController.text,
        _posteController.text,
        _selectedStatut,
        _sourceController.text,
        _notesController.text,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prospect != null ? 'Éditer prospect' : 'Nouveau prospect',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _entrepriseController,
                decoration: InputDecoration(
                  labelText: 'Entreprise',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _posteController,
                decoration: InputDecoration(
                  labelText: 'Poste',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatut,
                onChanged: (value) {
                  setState(() {
                    _selectedStatut = value ?? 'En cours';
                  });
                },
                items: ['En cours', 'Converti', 'Perdu']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.prospect != null ? 'Mettre à jour' : 'Créer',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
