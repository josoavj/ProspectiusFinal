import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';
import '../../providers/auth_provider.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  late Future<List<Account>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _usersFuture = context.read<AuthProvider>().getAllUsers();
  }

  Future<void> _openUserActions(Account user) async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null || currentUser.typeCompte != 'Administrateur') return;

    final action = await showDialog<_UserAction>(
      context: context,
      builder: (context) => _UserActionDialog(
        user: user,
        isCurrentUser: user.id == currentUser.id,
      ),
    );
    if (!mounted || action == null) return;

    final password = await _askForAdminPassword(
      action.delete ? 'Confirmer la suppression' : 'Confirmer la modification',
      action.delete
          ? 'Saisissez votre mot de passe pour supprimer définitivement ce compte.'
          : 'Saisissez votre mot de passe pour appliquer le nouveau rôle.',
    );
    if (!mounted || password == null) return;

    final success = action.delete
        ? await auth.deleteUser(user.id, password)
        : await auth.updateUserRole(user.id, action.role!, password);
    if (!mounted) return;
    if (success) {
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action.delete ? 'Compte supprimé.' : 'Rôle mis à jour.')),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    }
  }

  Future<String?> _askForAdminPassword(String title, String message) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe administrateur',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Account>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Impossible de charger les utilisateurs : ${snapshot.error}'));
        }
        final users = snapshot.data ?? const <Account>[];
        return RefreshIndicator(
          onRefresh: () async => setState(_reload),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Gestion des utilisateurs', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${users.length} compte(s) enregistré(s).'),
              const SizedBox(height: 16),
              _buildInformationCard(context),
              const SizedBox(height: 20),
              ...users.map((user) => Card(
                    child: ListTile(
                      onTap: () => _openUserActions(user),
                      leading: CircleAvatar(
                        child: Text(user.nom.isEmpty ? '?' : user.nom[0].toUpperCase()),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(
                        '${user.email}\n@${user.username} • Créé le '
                        '${user.dateCreation.day}/${user.dateCreation.month}/${user.dateCreation.year}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInformationCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Touchez un compte pour modifier son rôle ou le supprimer. '
              'Chaque action exige le mot de passe administrateur. '
              'Il doit toujours rester au moins un administrateur et la base accepte au maximum trois administrateurs.',
              style: TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAction {
  final String? role;
  final bool delete;

  const _UserAction({this.role, this.delete = false});
}

class _UserActionDialog extends StatefulWidget {
  final Account user;
  final bool isCurrentUser;

  const _UserActionDialog({
    required this.user,
    required this.isCurrentUser,
  });

  @override
  State<_UserActionDialog> createState() => _UserActionDialogState();
}

class _UserActionDialogState extends State<_UserActionDialog> {
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.user.typeCompte;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canDelete = !widget.isCurrentUser;
    return AlertDialog(
      title: Text(widget.user.fullName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.user.email),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(
              labelText: 'Rôle du compte',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Administrateur', child: Text('Administrateur')),
              DropdownMenuItem(value: 'Utilisateur', child: Text('Utilisateur')),
              DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
            ],
            onChanged: widget.isCurrentUser ? null : (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          if (widget.isCurrentUser)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Votre propre rôle et votre compte ne peuvent pas être modifiés ici.'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: canDelete
              ? () => Navigator.pop(context, const _UserAction(delete: true))
              : null,
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: const Text('Supprimer le compte'),
        ),
        TextButton(
          onPressed: widget.isCurrentUser || _role == widget.user.typeCompte
              ? null
              : () => Navigator.pop(context, _UserAction(role: _role)),
          child: const Text('Modifier le rôle'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
