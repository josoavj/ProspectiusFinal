import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/mysql_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import '../services/secure_storage_service.dart';
import '../providers/settings_provider.dart';
import '../services/excel_service.dart';
import '../core/di/service_locator.dart';
import '../utils/app_snackbars.dart';
import 'help_detail_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseController = TextEditingController();
  bool _isConnecting = false;
  bool _showEditMode = false;
  String? _error;
  bool _isBackingUp = false;
  String? _defaultBackupPath;
  String _dbVersion = 'Chargement...';
  String _connMode = 'Vérification...';
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedConfig();
      _loadDefaultBackupPath();
      _loadSystemHealth();
    });
  }

  Future<void> _loadSystemHealth() async {
    final version = await sl.mysqlService.getDatabaseVersion();
    final mode = sl.mysqlService.getConnectionMode();
    if (mounted) {
      setState(() {
        _dbVersion = version;
        _connMode = mode;
      });
    }
  }

  Future<void> _loadDefaultBackupPath() async {
    final path = await sl.backupService.getDefaultBackupDirectory();
    if (mounted) setState(() => _defaultBackupPath = path);
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = await _secureStorage.getDbPassword();
    if (mounted) {
      setState(() {
        _hostController.text = prefs.getString('db_host') ?? 'localhost';
        _portController.text = prefs.getString('db_port') ?? '3306';
        _userController.text = prefs.getString('db_user') ?? '';
        _passwordController.text = savedPassword ?? '';
        _databaseController.text = prefs.getString('db_name') ?? 'Prospectius';
      });
    }
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_host', _hostController.text);
    await prefs.setString('db_port', _portController.text);
    await prefs.setString('db_user', _userController.text);
    await prefs.setString('db_name', _databaseController.text);
    await _secureStorage.saveDbPassword(_passwordController.text);
  }

  void _handleChangeConfig() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final port = int.parse(_portController.text);
      final config = MySQLConfig(
        host: _hostController.text,
        port: port,
        user: _userController.text,
        password: _passwordController.text,
        database: _databaseController.text,
      );

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.configureDatabase(config);

      if (success && mounted) {
        await _saveConfig();
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _showEditMode = false;
          });
          AppSnackBars.showSuccess(context, 'Configuration mise à jour avec succès');
        }
      } else if (mounted) {
        setState(() {
          _error = authProvider.error ?? 'Erreur de connexion';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isConnecting = false;
      });
    }
  }

  void _showChangeConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Changer la configuration'),
          content: const SizedBox(
            width: 400,
            child: Text(
              'Vous êtes sur le point de modifier la configuration de la base de données. '
              'Cette action est risquée et pourrait déconnecter l\'application. Continuer ?',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _showEditMode = true);
              },
              child: const Text('Continuer', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
  }

  void _handleBackup({bool customPath = false}) async {
    String? selectedDir;
    
    if (customPath) {
      final excelService = ExcelService();
      selectedDir = await excelService.pickExportDirectory();
      if (selectedDir == null) return;
    }

    setState(() => _isBackingUp = true);
    
    try {
      final backupService = sl.backupService;
      final path = await backupService.createFullBackup(directoryPath: selectedDir);
      
      if (mounted) {
        if (path != null) {
          AppSnackBars.showSuccess(context, 'Sauvegarde terminée avec succès !\nEmplacement : $path');
        } else {
          AppSnackBars.showError(context, 'Échec de la sauvegarde de la base de données');
        }
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _navigateToHelp(String title, String type) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HelpDetailScreen(title: title, type: type),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.05, 0.0); // Léger glissement de droite
          const end = Offset.zero;
          const curve = Curves.easeOutCubic; // Courbe fluide

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final warningColor = Colors.orange;
    final userRole = context.watch<AuthProvider>().currentUser?.typeCompte;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Base de données (Uniquement pour Admin)
            if (userRole == 'Administrateur') ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: warningColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage_rounded, color: warningColor),
                        const SizedBox(width: 12),
                        Text(
                          'Base de données',
                          style: TextStyle(fontWeight: FontWeight.bold, color: warningColor, fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: warningColor, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Risqué', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Modifier la configuration réseau de la base de données. Attention, une erreur de saisie bloquera l\'accès aux prospects.',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    if (!_showEditMode)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildConfigInfo('Hôte', _hostController.text, colorScheme),
                          _buildConfigInfo('Port', _portController.text, colorScheme),
                          _buildConfigInfo('Base', _databaseController.text, colorScheme),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _showChangeConfigDialog,
                              icon: const Icon(Icons.settings_input_component_outlined, size: 18),
                              label: const Text('Modifier la configuration'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: warningColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _buildEditFields(colorScheme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Section Apparence
            Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return _buildSettingSection(
                  icon: Icons.palette_outlined,
                  title: 'Confort visuel',
                  subtitle: 'Adaptez l\'interface à vos préférences de travail',
                  colorScheme: colorScheme,
                  children: [
                    const Text('Ambiance de l\'application', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Choisissez un mode clair pour le jour ou sombre pour reposer vos yeux.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Clair')),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Sombre')),
                          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined), label: Text('Auto')),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) => settings.setThemeMode(newSelection.first),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lisibilité du texte', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('Ajustez la taille des caractères pour un confort optimal.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        Text('${(settings.fontSizeFactor * 100).toInt()}%', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: settings.fontSizeFactor,
                      min: 0.8, max: 1.4, divisions: 6,
                      activeColor: colorScheme.primary,
                      onChanged: (double value) => settings.setFontSizeFactor(value),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Section Système
            _buildSettingSection(
              icon: Icons.monitor_heart_outlined,
              title: 'Santé du système',
              subtitle: 'Diagnostic technique de votre installation',
              colorScheme: colorScheme,
              children: [
                _buildSystemInfoItem('Version Application', 'v1.2.0 Stable', colorScheme),
                _buildSystemInfoItem('Moteur de base de données', _dbVersion, colorScheme),
                _buildSystemInfoItem('Mode de connexion SQL', _connMode, colorScheme),
                _buildSystemInfoItem('Système d\'exploitation', '${Platform.operatingSystem.toUpperCase()} (${Platform.operatingSystemVersion.split(' ')[0]})', colorScheme),
                _buildSystemInfoItem('Architecture processeur', Platform.localHostname, colorScheme, customValue: Platform.isLinux ? 'Linux Desktop' : 'Windows Desktop'),
                _buildSystemInfoItem('Statut Serveur', 'Opérationnel', colorScheme, isSuccess: true),
              ],
            ),
            const SizedBox(height: 16),

            // Section Aide & Documentation (Le nouveau "A propos" complet)
            _buildSettingSection(
              icon: Icons.help_outline_rounded,
              title: 'Besoin d\'aide ?',
              subtitle: 'Guides pour tirer le meilleur parti de Prospectius',
              colorScheme: colorScheme,
              children: [
                _buildDocumentationItem(
                  context,
                  icon: Icons.auto_stories_outlined,
                  title: 'Guide de démarrage rapide',
                  desc: 'Tout ce qu\'il faut savoir pour bien débuter avec vos premiers prospects.',
                  onTap: () => _navigateToHelp('Démarrage Rapide', 'start'),
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.keyboard_alt_outlined,
                  title: 'Astuces clavier',
                  desc: 'Gagnez du temps au quotidien grâce aux raccourcis essentiels.',
                  onTap: () => _navigateToHelp('Raccourcis Clavier', 'keyboard'),
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: 'Sécurité de vos données',
                  desc: 'Comprendre comment vos informations sont protégées localement.',
                  onTap: () => _navigateToHelp('Sécurité & Confidentialité', 'security'),
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.alternate_email_outlined,
                  title: 'Contacter l\'assistance',
                  desc: 'Une question ou une suggestion ? Notre équipe est à votre écoute.',
                  onTap: () => _navigateToHelp('Support & Contact', 'support'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Maintenance & Sauvegarde
            if (userRole == 'Administrateur')
              _buildSettingSection(
                icon: Icons.shield_outlined,
                title: 'Sécurité & Sauvegarde',
                subtitle: 'Protégez vos données et maintenez la base',
                colorScheme: colorScheme,
                children: [
                  _buildActionItem(
                    context,
                    icon: Icons.backup_outlined,
                    title: 'Sauvegarde standard',
                    desc: 'Dossier par défaut : ${_defaultBackupPath ?? "Chargement..."}',
                    onTap: _isBackingUp ? () {} : () => _handleBackup(customPath: false),
                    trailing: _isBackingUp 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                  const Divider(height: 32),
                  _buildActionItem(
                    context,
                    icon: Icons.drive_file_move_outlined,
                    title: 'Sauvegarde personnalisée',
                    desc: 'Choisissez manuellement l\'emplacement du fichier (Clé USB, Disque...)',
                    onTap: _isBackingUp ? () {} : () => _handleBackup(customPath: true),
                    trailing: const Icon(Icons.folder_open_outlined, size: 18),
                  ),
                  const Divider(height: 32),
                  _buildActionItem(
                    context,
                    icon: Icons.delete_sweep_outlined,
                    title: 'Purger les prospects supprimés',
                    desc: 'Supprime définitivement les prospects mis à la corbeille il y a plus de 30 jours.',
                    onTap: () => _showPurgeConfirmDialog(context),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String title, required String desc, required VoidCallback onTap, Widget? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _showPurgeConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la purge'),
        content: const Text('Voulez-vous supprimer définitivement les données marquées comme supprimées depuis plus de 30 jours ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final prospectProvider = context.read<ProspectProvider>();
              final navigator = Navigator.of(context);
              
              await prospectProvider.purgeOldData(30);
              
              if (!context.mounted) return;
              navigator.pop();
              AppSnackBars.showSuccess(context, 'Purge terminée avec succès');
            },
            child: const Text('Purger maintenant', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigInfo(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSystemInfoItem(String label, String value, ColorScheme colorScheme, {bool isSuccess = false, String? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          Row(
            children: [
              if (isSuccess) ...[
                const Icon(Icons.check_circle, color: Color(0xFF06CE70), size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                customValue ?? value, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13,
                  color: isSuccess ? const Color(0xFF06CE70) : null,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentationItem(BuildContext context, {required IconData icon, required String title, required String desc, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildEditFields(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildTextField(_hostController, 'Hôte'),
        const SizedBox(height: 12),
        _buildTextField(_portController, 'Port', type: TextInputType.number),
        const SizedBox(height: 12),
        _buildTextField(_userController, 'Utilisateur'),
        const SizedBox(height: 12),
        _buildTextField(_passwordController, 'Mot de passe', obscure: true),
        const SizedBox(height: 12),
        _buildTextField(_databaseController, 'Base de données'),
        const SizedBox(height: 16),
        if (_error != null) _buildErrorMessage(colorScheme),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _handleChangeConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06CE70),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isConnecting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () { _loadSavedConfig(); setState(() { _showEditMode = false; _error = null; }); },
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
