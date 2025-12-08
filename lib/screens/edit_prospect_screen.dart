import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../utils/text_formatter.dart';

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
  late String _selectedType;
  late String _selectedStatus;
  late TextEditingController _interactionDescriptionController;
  late String _selectedInteractionType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.prospect.nom);
    _prenomController = TextEditingController(text: widget.prospect.prenom);
    _emailController = TextEditingController(text: widget.prospect.email);
    _telephoneController =
        TextEditingController(text: widget.prospect.telephone);
    _adresseController = TextEditingController(text: widget.prospect.adresse);
    _selectedType = widget.prospect.type;
    _selectedStatus = widget.prospect.status;
    _interactionDescriptionController = TextEditingController();
    _selectedInteractionType = 'appel';
    // Load interactions after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInteractions();
    });
  }

  void _loadInteractions() {
    final prospectProvider = context.read<ProspectProvider>();
    prospectProvider.loadInteractions(widget.prospect.id);
  }

  void _handleSaveProspect() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    // Afficher le dialogue de confirmation
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: AlertDialog(
                title: const Text('Confirmer la modification'),
                content: const Text(
                    'Êtes-vous sûr de vouloir modifier ce prospect?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 206, 112),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _isLoading = true);

    final success = await prospectProvider.updateProspect(
      authProvider.currentUser!.id,
      widget.prospect.id,
      {
        'nomp': _nomController.text,
        'prenomp': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'adresse': _adresseController.text,
        'type': _selectedType,
        'status': _selectedStatus,
      },
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Afficher le message de succès dans un dialogue
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: AlertDialog(
              title: const Text('Succès'),
              content: const Text('Prospect modifié avec succès'),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 206, 112),
                  ),
                  onPressed: () {
                    // Créer le prospect mis à jour
                    final updatedProspect = Prospect(
                      id: widget.prospect.id,
                      nom: _nomController.text,
                      prenom: _prenomController.text,
                      email: _emailController.text,
                      telephone: _telephoneController.text,
                      adresse: _adresseController.text,
                      type: _selectedType,
                      status: _selectedStatus,
                      creation: widget.prospect.creation,
                      dateUpdate: DateTime.now(),
                      assignation: widget.prospect.assignation,
                    );
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    Navigator.of(context)
                        .pop(updatedProspect); // Retourner l'objet
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _handleSaveAndAddInteraction() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    // Afficher le dialogue de confirmation
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: AlertDialog(
                title: const Text('Mettre à jour et ajouter une interaction'),
                content: const Text(
                  'Les informations du prospect seront mises à jour, puis vous pourrez ajouter une interaction.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 206, 112),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _isLoading = true);

    // Mettre à jour le prospect
    final success = await prospectProvider.updateProspect(
      authProvider.currentUser!.id,
      widget.prospect.id,
      {
        'nomp': _nomController.text,
        'prenomp': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'adresse': _adresseController.text,
        'type': _selectedType,
        'status': _selectedStatus,
      },
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Afficher le formulaire d'interaction dans la dialogue
      _showAddInteractionDialog();
    }
  }

  void _showAddInteractionDialog() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 550,
                  maxHeight: 650,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 6, 206, 112)
                            .withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ajouter une interaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _interactionDescriptionController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 6, 206, 112)
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 6, 206, 112),
                                  ),
                                ),
                                child: Text(
                                  'Prospect: ${_nomController.text} ${_prenomController.text}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
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
                                items: [
                                  'appel',
                                  'email',
                                  'sms',
                                  'reunion',
                                  'message',
                                  'autre'
                                ]
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                decoration: InputDecoration(
                                  labelText: 'Type d\'interaction',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _interactionDescriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: 'Décrivez votre interaction...',
                                ),
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _interactionDescriptionController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ignorer'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 6, 206, 112),
                            ),
                            onPressed: _interactionDescriptionController
                                    .text.isEmpty
                                ? null
                                : () async {
                                    if (authProvider.currentUser == null)
                                      return;

                                    setState(() => _isLoading = true);

                                    await prospectProvider.createInteraction(
                                      widget.prospect.id,
                                      authProvider.currentUser!.id,
                                      _selectedInteractionType,
                                      _interactionDescriptionController.text,
                                      DateTime.now().toUtc(),
                                    );

                                    setState(() => _isLoading = false);

                                    _interactionDescriptionController.clear();

                                    if (mounted) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Interaction ajoutée avec succès'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            child: Text(
                              _isLoading ? 'Ajout...' : 'Ajouter',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _interactionDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre à jour le prospect'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Informations du prospect
                  Text(
                    'Informations du prospect',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _telephoneController,
                            decoration: InputDecoration(
                              labelText: 'Téléphone',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _adresseController,
                            decoration: InputDecoration(
                              labelText: 'Adresse',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value ?? 'particulier';
                              });
                            },
                            items: ['particulier', 'societe', 'organisation']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Type',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                              'perdu',
                              'converti'
                            ]
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Statut',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ancien statut: ${widget.prospect.status}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleSaveProspect,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Enregistrer',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleSaveAndAddInteraction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 6, 206, 112),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Ajouter interaction',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Section Historique des interactions
                  Text(
                    'Historique des interactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Consumer<ProspectProvider>(
                    builder: (context, prospectProvider, _) {
                      if (prospectProvider.interactions.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Aucune interaction',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: prospectProvider.interactions.length,
                        itemBuilder: (context, index) {
                          final interaction =
                              prospectProvider.interactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                _getInteractionIcon(interaction.type),
                              ),
                              title: Text(
                                  TextFormatter.capitalize(interaction.type)),
                              subtitle: Text(interaction.note),
                              trailing: Text(
                                '${interaction.dateInteraction.day}/${interaction.dateInteraction.month}/${interaction.dateInteraction.year}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getInteractionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appel':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'reunion':
        return Icons.people;
      default:
        return Icons.message;
    }
  }
}
