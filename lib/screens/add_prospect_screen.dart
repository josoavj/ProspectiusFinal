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
  late TextEditingController _interactionNoteController;
  String _selectedType = 'particulier';
  String _selectedStatus = 'nouveau';
  String _selectedInteractionType = 'appel';

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
    _interactionNoteController = TextEditingController();
    _selectedType = widget.prospect?.type ?? 'particulier';
    _selectedStatus = widget.prospect?.status ?? 'nouveau';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _interactionNoteController.dispose();
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
      // Créer le prospect et l'interaction en même temps
      final prospectCreated = await prospectProvider.createProspect(
        authProvider.currentUser!.id,
        _nomController.text,
        _prenomController.text,
        _emailController.text,
        _telephoneController.text,
        _adresseController.text,
        _selectedType,
      );

      // Si le prospect est créé, créer l'interaction
      if (prospectCreated && _interactionNoteController.text.isNotEmpty) {
        // Trouver le prospect créé en le cherchant par nom et prénom
        // (l'assignation est garantie d'être l'utilisateur actuel)
        final createdProspect = prospectProvider.prospects.firstWhere(
          (p) =>
              p.nom == _nomController.text &&
              p.prenom == _prenomController.text,
          orElse: () {
            // Si pour une raison quelconque on ne trouve pas le prospect,
            // on retourne null et on n'ajoute pas d'interaction
            return Prospect(
              id: -1,
              assignation: 0,
              nom: '',
              prenom: '',
              email: '',
              telephone: '',
              adresse: '',
              type: '',
              status: '',
              creation: DateTime.now(),
              dateUpdate: DateTime.now(),
            );
          },
        );

        // Vérifier que le prospect a bien été créé
        if (createdProspect.id != -1) {
          await prospectProvider.createInteraction(
            createdProspect.id,
            authProvider.currentUser!.id,
            _selectedInteractionType,
            _interactionNoteController.text,
            DateTime.now().toUtc(),
          );
        }
      }
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
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                        _selectedType = value ?? 'particulier';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Type',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ['particulier', 'societe', 'organisation']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'nouveau';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      'nouveau',
                      'interesse',
                      'negociation',
                      'converti',
                      'perdu'
                    ]
                        .map(
                          (status) => DropdownMenuItem(
                              value: status, child: Text(status)),
                        )
                        .toList(),
                  ),
                  // Afficher les champs d'interaction uniquement à la création
                  if (widget.prospect == null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Interaction initiale',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedInteractionType,
                      onChanged: (value) {
                        setState(() {
                          _selectedInteractionType = value ?? 'appel';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Type d\'interaction',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['appel', 'email', 'reunion', 'message', 'autre']
                          .map(
                            (type) => DropdownMenuItem(
                                value: type, child: Text(type)),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _interactionNoteController,
                      decoration: InputDecoration(
                        labelText: 'Note d\'interaction',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText:
                            'Décrivez votre interaction avec le prospect...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.prospect != null ? 'Mettre à jour' : 'Créer',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
