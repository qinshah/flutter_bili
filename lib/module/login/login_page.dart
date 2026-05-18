import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../module/login/model/user_m.dart';
import '../../service/auth_s.dart';
import 'widget/qr_login_dialog.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthS>();
    final users = auth.users;

    return Scaffold(
      appBar: AppBar(title: const Text('账号管理')),
      body: ListView(
        children: [
          ...users.map((user) => _buildUserTile(context, auth, user)),
          _buildAddAccountTile(context),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, AuthS auth, UserM user) {
    final isCurrent = auth.curUser?.key == user.key;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.person),
      ),
      title: Text('账号 ${user.key}'),
      subtitle: Text(
        'SESSDATA: ${user.sessdata.isNotEmpty ? '${user.sessdata.substring(0, user.sessdata.length.clamp(0, 8))}...' : '空'}',
      ),
      trailing: isCurrent
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () {
        auth.switchUser(user);
        if (context.mounted) context.pop();
      },
    );
  }

  Widget _buildAddAccountTile(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
      ),
      title: const Text('添加账号'),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showQrLoginDialog(context),
    );
  }

  void _showQrLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QrLoginDialog(),
    );
  }
}
