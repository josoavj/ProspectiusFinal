import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/mysql_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/secure_storage_service.dart';
import '../providers/settings_provider.dart';

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
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedConfig();
    });
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuration mise à jour avec succès')),
          );
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
                  title: 'Apparence',
                  subtitle: 'Personnalisez votre interface visuelle',
                  colorScheme: colorScheme,
                  children: [
                    const Text('Mode de thème', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                        const Text('Taille du texte', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
              icon: Icons.terminal_outlined,
              title: 'Environnement & Système',
              subtitle: 'Détails techniques de l\'instance',
              colorScheme: colorScheme,
              children: [
                _buildSystemInfoItem('Version Application', '1.1.0 Stable (Build 2025.01)', colorScheme),
                _buildSystemInfoItem('Plateforme Exécution', Platform.operatingSystem.toUpperCase(), colorScheme),
                _buildSystemInfoItem('Moteur de Rendu', 'Flutter 3.x (Skia/Impeller)', colorScheme),
                _buildSystemInfoItem('Protocole Database', 'MySQL driver 0.20.0', colorScheme),
              ],
            ),
            const SizedBox(height: 16),

            // Section Aide & Documentation (Le nouveau "A propos" complet)
            _buildSettingSection(
              icon: Icons.menu_book_outlined,
              title: 'Ressources & Documentation',
              subtitle: 'Guides et informations utiles',
              colorScheme: colorScheme,
              children: [
                _buildDocumentationItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Manuel d\'utilisation',
                  desc: 'Apprenez à maîtriser le pipeline Kanban et les automatisations.',
                  onTap: () {},
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.keyboard_command_key_outlined,
                  title: 'Raccourcis Clavier',
                  desc: 'Optimisez votre saisie avec les combinaisons de touches (Ctrl+N, Ctrl+F).',
                  onTap: () {},
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.security_outlined,
                  title: 'Politique de Confidentialité',
                  desc: 'Consultez comment vos données MySQL sont sécurisées localement.',
                  onTap: () {},
                ),
                _buildDocumentationItem(
                  context,
                  icon: Icons.support_agent_outlined,
                  title: 'Support Technique',
                  desc: 'Un problème ? Contactez l\'équipe APEXNova Labs via GitHub.',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildSystemInfoItem(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
