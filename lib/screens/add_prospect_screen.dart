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
  late TextEditingController _adresseController;
  String _selectedType = 'prospect';
  String _selectedStatus = 'nouveau';

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
    _adresseController = TextEditingController(
      text: widget.prospect?.adresse ?? '',
    );
    _selectedType = widget.prospect?.type ?? 'prospect';
    _selectedStatus = widget.prospect?.status ?? 'nouveau';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    if (widget.prospect != null) {
      await prospectProvider
          .updateProspect(authProvider.currentUser!.id, widget.prospect!.id, {
        'nomp': _nomController.text,
        'prenomp': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'adresse': _adresseController.text,
        'type': _selectedType,
        'status': _selectedStatus,
      });
    } else {
      await prospectProvider.createProspect(
        authProvider.currentUser!.id,
        _nomController.text,
        _prenomController.text,
        _emailController.text,
        _telephoneController.text,
        _adresseController.text,
        _selectedType,
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
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value ?? 'prospect';
                  });
                },
                items: ['prospect', 'client', 'fournisseur']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'nouveau';
                  });
                },
                items: [
                  'nouveau',
                  'interesse',
                  'negociation',
                  'converti',
                  'perdu'
                ]
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
