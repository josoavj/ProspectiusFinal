import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mysql_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hostController.text = prefs.getString('db_host') ?? 'localhost';
      _portController.text = prefs.getString('db_port') ?? '3306';
      _userController.text = prefs.getString('db_user') ?? 'root';
      _passwordController.text = prefs.getString('db_password') ?? 'root';
      _databaseController.text = prefs.getString('db_name') ?? 'Prospectius';
    });
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_host', _hostController.text);
    await prefs.setString('db_port', _portController.text);
    await prefs.setString('db_user', _userController.text);
    await prefs.setString('db_password', _passwordController.text);
    await prefs.setString('db_name', _databaseController.text);
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
            const SnackBar(
              content: Text('Configuration mise à jour avec succès'),
              duration: Duration(seconds: 2),
            ),
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
          content: const Text(
            'Vous êtes sur le point de modifier la configuration de la base de données. '
            'Cette action est risquée et pourrait déconnecter l\'application. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showEditMode = true;
                });
              },
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.orange),
              ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Base de données (Risquée)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Base de données',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Risqué',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Modifier la configuration de la base de données peut déconnecter l\'application.',
                  ),
                  const SizedBox(height: 12),
                  if (!_showEditMode)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration actuelle:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        _buildConfigInfo('Hôte', _hostController.text),
                        _buildConfigInfo('Port', _portController.text),
                        _buildConfigInfo('Utilisateur', _userController.text),
                        _buildConfigInfo(
                            'Base de données', _databaseController.text),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _showChangeConfigDialog,
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier la configuration'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TextField(
                          controller: _hostController,
                          decoration: InputDecoration(
                            labelText: 'Hôte',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _portController,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Utilisateur',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _databaseController,
                          decoration: InputDecoration(
                            labelText: 'Base de données',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _isConnecting
                                      ? null
                                      : _handleChangeConfig,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isConnecting
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
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _loadSavedConfig();
                                    setState(() {
                                      _showEditMode = false;
                                      _error = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[400],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section Apparence
            _buildSettingSection(
              icon: Icons.palette,
              title: 'Apparence',
              subtitle: 'Personnalisez l\'interface',
              children: [
                _buildSettingItem(
                  icon: Icons.brightness_6,
                  label: 'Mode sombre',
                  trailing: Switch(value: false, onChanged: (_) {}),
                ),
                _buildSettingItem(
                  icon: Icons.text_fields,
                  label: 'Taille du texte',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Section Notifications
            _buildSettingSection(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérez vos préférences',
              children: [
                _buildSettingItem(
                  icon: Icons.notifications_active,
                  label: 'Notifications activées',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Section À propos
            _buildSettingSection(
              icon: Icons.info,
              title: 'À propos',
              subtitle: 'Informations de l\'application',
              children: [
                _buildSettingItem(
                  icon: Icons.info_outlined,
                  label: 'Version',
                  trailing: const Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          trailing,
        ],
      ),
    );
  }
}
