import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../utils/text_formatter.dart';
import '../utils/app_snackbars.dart';

class AddProspectScreen extends StatefulWidget {
  final Prospect? prospect;

  const AddProspectScreen({super.key, this.prospect});

  static Future<void> show(BuildContext context, {Prospect? prospect}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) => AddProspectScreen(prospect: prospect),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<AddProspectScreen> createState() => _AddProspectScreenState();
}

class _AddProspectScreenState extends State<AddProspectScreen> {
  int _currentStep = 1; // 1: Perso/Pro, 2: Digital, 3: Notes/RGPD, 4: Interaction, 5: Récap
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late List<TextEditingController> _phoneControllers;
  late TextEditingController _adresseController;
  late TextEditingController _sourceController;
  late TextEditingController _nomEntrepriseController;
  late TextEditingController _posteController;
  late TextEditingController _linkedinController;
  late TextEditingController _siteWebController;
  late TextEditingController _descriptionController;
  late TextEditingController _consentementSourceController;
  late TextEditingController _interactionNoteController;

  String _selectedType = 'particulier';
  String _selectedStatus = 'interesse';
  String _selectedPriorite = 'moyenne';
  String _selectedInteractionType = 'appel';
  DateTime? _consentementDate = DateTime.now(); // Par défaut à aujourd'hui

  @override
  void initState() {
    super.initState();
    final p = widget.prospect;
    _nomController = TextEditingController(text: p?.nom ?? '');
    _prenomController = TextEditingController(text: p?.prenom ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    
    // Initialisation des téléphones (gestion multiple)
    if (p?.telephone != null && p!.telephone.isNotEmpty) {
      _phoneControllers = p.telephone.split(', ').map((t) => TextEditingController(text: t)).toList();
    } else {
      _phoneControllers = [TextEditingController()];
    }

    _adresseController = TextEditingController(text: p?.adresse ?? '');
    _sourceController = TextEditingController(text: p?.source ?? '');
    _nomEntrepriseController = TextEditingController(text: p?.nomEntreprise ?? '');
    _posteController = TextEditingController(text: p?.poste ?? '');
    _linkedinController = TextEditingController(text: p?.linkedinUrl ?? '');
    _siteWebController = TextEditingController(text: p?.siteWeb ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _consentementSourceController = TextEditingController(text: p?.consentementSource ?? '');
    _interactionNoteController = TextEditingController();

    _selectedType = p?.type ?? 'particulier';
    _selectedStatus = p?.status ?? 'interesse';
    _selectedPriorite = p?.priorite ?? 'moyenne';
    _consentementDate = p?.consentementDate;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    for (var c in _phoneControllers) {
      c.dispose();
    }
    _adresseController.dispose();
    _sourceController.dispose();
    _nomEntrepriseController.dispose();
    _posteController.dispose();
    _linkedinController.dispose();
    _siteWebController.dispose();
    _descriptionController.dispose();
    _consentementSourceController.dispose();
    _interactionNoteController.dispose();
    super.dispose();
  }

  void _addPhoneField() {
    if (_phoneControllers.length < 3) {
      setState(() => _phoneControllers.add(TextEditingController()));
    } else {
      AppSnackBars.showWarning(context, 'Maximum 3 numéros autorisés');
    }
  }

  void _removePhoneField(int index) {
    if (_phoneControllers.length > 1) {
      setState(() {
        _phoneControllers[index].dispose();
        _phoneControllers.removeAt(index);
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_nomController.text.trim().isEmpty) {
        AppSnackBars.showError(context, 'Le nom est obligatoire');
        return;
      }
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  String _getJoinedPhones() {
    return _phoneControllers
        .map((c) => '261${c.text.replaceAll(' ', '')}')
        .where((t) => t.length > 3)
        .join(', ');
  }

  void _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    if (authProvider.currentUser == null) return;

    final phoneData = _getJoinedPhones();

    final data = {
      'userId': authProvider.currentUser!.id,
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'email': _emailController.text,
      'telephone': phoneData,
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
      'consentementDate': _consentementDate,
      'consentementSource': _consentementSourceController.text,
    };

    bool success;
    if (widget.prospect != null) {
      final updateData = {
        'nomp': _nomController.text,
        'prenomp': _prenomController.text,
        'email': _emailController.text,
        'telephone': phoneData,
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
      AppSnackBars.showSuccess(context, widget.prospect != null ? 'Prospect mis à jour' : 'Prospect créé');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity, 
                maxHeight: isDesktop ? 750 : double.infinity
              ),
              margin: isDesktop ? const EdgeInsets.all(32) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 0),
                boxShadow: isDesktop ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25), 
                    blurRadius: 30, 
                    offset: const Offset(0, 15)
                  )
                ] : null,
              ),
              child: Column(
                children: [
                  _buildHeader(colorScheme),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStep(context),
                    ),
                  ),
                  _buildFooter(colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.prospect != null ? 'Édition Prospect' : 'Nouveau Prospect',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStepIndicator(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ColorScheme colorScheme) {
    final steps = ['Infos', 'Digital', 'Notes', 'Échange', 'Récap'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isEven) {
          final stepIdx = index ~/ 2 + 1;
          final isActive = _currentStep >= stepIdx;
          final isCurrent = _currentStep == stepIdx;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: colorScheme.primary, width: 4, strokeAlign: BorderSide.strokeAlignOutside) : null,
                  ),
                  child: Center(
                    child: isActive && !isCurrent 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text('$stepIdx', style: TextStyle(color: isActive ? Colors.white : colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(steps[stepIdx-1], style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }
        return Container(width: 20, height: 2, margin: const EdgeInsets.only(bottom: 14), color: _currentStep > (index ~/ 2 + 1) ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.3));
      }),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 1: return _buildStepPersoPro();
      case 2: return _buildStepDigital();
      case 3: return _buildStepNotesRGPD();
      case 4: return _buildStepInteraction();
      case 5: return _buildStepSummary();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStepPersoPro() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations Personnelles'),
          _buildField(_nomController, 'Nom', Icons.person),
          const SizedBox(height: 16),
          _buildField(_prenomController, 'Prénom', Icons.person_outline),
          const SizedBox(height: 16),
          _buildField(_emailController, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          
          // Gestion des téléphones multiples
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Téléphone(s)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
              TextButton.icon(
                onPressed: _addPhoneField,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          ...List.generate(_phoneControllers.length, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildField(
                    _phoneControllers[index], 
                    'Numéro ${index + 1}', 
                    Icons.phone_outlined, 
                    type: TextInputType.phone,
                    prefixText: '+261 ',
                    formatters: [PhoneInputFormatter()],
                    maxLength: 9, // 7 chiffres + 2 espaces
                  ),
                ),
                if (_phoneControllers.length > 1)
                  IconButton(
                    onPressed: () => _removePhoneField(index),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                  ),
              ],
            ),
          )),

          const SizedBox(height: 24),
          _buildSectionTitle('Profil Professionnel'),
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Type de contact', _selectedType, ['particulier', 'societe', 'organisation'], (val) => setState(() => _selectedType = val!), labelFormatter: TextFormatter.formatType),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text('STATUT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('Intéressé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedType != 'particulier') ...[
            const SizedBox(height: 16),
            _buildField(
              _nomEntrepriseController, 
              _selectedType == 'organisation' ? 'Organisation' : 'Entreprise',
              _selectedType == 'organisation' ? Icons.account_balance : Icons.business
            ),
            const SizedBox(height: 16),
            _buildField(_posteController, 'Poste occupé', Icons.work_outline),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDigital() {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Présence Digitale'),
          _buildField(_sourceController, 'Source (ex: LinkedIn, Salon...)', Icons.source_outlined),
          const SizedBox(height: 16),
          _buildField(_siteWebController, 'Site Web', Icons.language, type: TextInputType.url),
          const SizedBox(height: 16),
          _buildField(_linkedinController, 'Profil LinkedIn', Icons.link, type: TextInputType.url),
          const SizedBox(height: 24),
          _buildSectionTitle('Localisation'),
          _buildField(_adresseController, 'Adresse complète', Icons.location_on_outlined, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildStepNotesRGPD() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Notes & Contexte'),
          _buildField(_descriptionController, 'Commentaires libres', Icons.note_outlined, maxLines: 5),
          const SizedBox(height: 32),
          
          // Section RGPD re-stylisée
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green[600], size: 20),
              const SizedBox(width: 10),
              const Text('Protection & Consentement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Prouvez que ce prospect a accepté d\'être contacté pour rester en conformité avec la loi.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05), 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: Colors.green.withValues(alpha: 0.1))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('D\'où provient son accord ?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickSourceChip('Formulaire web', Icons.language),
                    _buildQuickSourceChip('Appel direct', Icons.phone_callback),
                    _buildQuickSourceChip('Email', Icons.alternate_email),
                    _buildQuickSourceChip('Rencontre / Salon', Icons.handshake_outlined),
                    _buildQuickSourceChip('Autre', Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField(
                  _consentementSourceController, 
                  'Détails de la source (optionnel)', 
                  Icons.edit_note,
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date du consentement', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          _consentementDate == null ? 'Non définie' : '${_consentementDate!.day}/${_consentementDate!.month}/${_consentementDate!.year}',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
                        if (date != null) setState(() => _consentementDate = date);
                      },
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Changer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSourceChip(String label, IconData icon) {
    final isSelected = _consentementSourceController.text == label;
    final colorScheme = Theme.of(context).colorScheme;
    
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : colorScheme.primary),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _consentementSourceController.text = label;
          });
        }
      },
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildStepInteraction() {
    if (widget.prospect != null) {
       return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.info_outline, size: 48, color: Colors.blue), const SizedBox(height: 16), const Text('L\'interaction initiale ne peut être modifiée.')]));
    }
    return SingleChildScrollView(
      key: const ValueKey(4),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Interaction Initiale'),
          _buildDropdown('Type d\'échange', _selectedInteractionType, ['appel', 'email', 'reunion', 'message', 'autre'], (val) => setState(() => _selectedInteractionType = val!), labelFormatter: TextFormatter.formatInteractionType),
          const SizedBox(height: 16),
          _buildField(_interactionNoteController, 'Compte rendu de l\'échange', Icons.chat_bubble_outline, maxLines: 5),
          const SizedBox(height: 24),
          _buildDropdown('Priorité estimée', _selectedPriorite, ['basse', 'moyenne', 'haute'], (val) => setState(() => _selectedPriorite = val!), labelFormatter: TextFormatter.formatPriority),
        ],
      ),
    );
  }

  Widget _buildStepSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      key: const ValueKey(5),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fact_check_outlined, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              const Text('Vérification finale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildRecapSection(
            'COORDONNÉES',
            Icons.contact_mail_outlined,
            [
              _buildSummaryItem('Identité', '${_nomController.text.toUpperCase()} ${_prenomController.text}'),
              _buildSummaryItem('Email', _emailController.text),
              _buildSummaryItem('Téléphone(s)', _getJoinedPhones()),
              _buildSummaryItem('Adresse', _adresseController.text),
            ],
          ),
          
          _buildRecapSection(
            'PROFIL & SOURCE',
            Icons.business_center_outlined,
            [
              _buildSummaryItem('Type', TextFormatter.formatType(_selectedType)),
              if (_selectedType != 'particulier') 
                _buildSummaryItem(_selectedType == 'organisation' ? 'Organisation' : 'Entreprise', _nomEntrepriseController.text),
              _buildSummaryItem('Poste', _posteController.text),
              _buildSummaryItem('Priorité', _selectedPriorite.toUpperCase(), valueColor: _getPriorityColor(_selectedPriorite)),
              _buildSummaryItem('Source lead', _sourceController.text),
            ],
          ),

          _buildRecapSection(
            'PRÉSENCE DIGITALE',
            Icons.language,
            [
              _buildSummaryItem('Site Web', _siteWebController.text),
              _buildSummaryItem('LinkedIn', _linkedinController.text),
            ],
          ),

          _buildRecapSection(
            'SANTÉ LÉGALE (RGPD)',
            Icons.verified_user_outlined,
            [
              _buildSummaryItem('Consentement', _consentementDate == null ? 'Non défini' : 'Accordé le ${TextFormatter.formatDate(_consentementDate!)}'),
              _buildSummaryItem('Preuve', _consentementSourceController.text),
            ],
          ),

          if (_interactionNoteController.text.isNotEmpty)
            _buildRecapSection(
              'INTERACTION INITIALE',
              Icons.chat_bubble_outline,
              [
                _buildSummaryItem('Canal', TextFormatter.formatInteractionType(_selectedInteractionType)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _interactionNoteController.text,
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Précédent'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _currentStep == 5 ? _handleSave : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == 5 ? const Color(0xFF06CE70) : colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              _currentStep == 5 ? 'Confirmer & Enregistrer' : 'Suivant',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5)),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1, String? prefixText, List<TextInputFormatter>? formatters, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      inputFormatters: formatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
        counterText: '', // Cacher le compteur de caractères
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged, {String Function(String)? labelFormatter}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelFormatter != null ? labelFormatter(e) : e))).toList(),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? valueColor}) {
    if (value.trim().isEmpty || value == '261') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapSection(String title, IconData icon, List<Widget> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute': return Colors.redAccent;
      case 'moyenne': return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }
}
