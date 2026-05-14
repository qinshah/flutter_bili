import 'package:flutter/material.dart';
import 'package:flutter_bili/route/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../service/auth_s.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthS>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('账号与安全'),
          _buildListTile(
            icon: const Icon(Icons.person_outline),
            title: '个人资料',
            subtitle: auth.isLogin ? '已登录' : '未登录',
            onTap: () => _showProfileDialog(context),
          ),
          _buildListTile(
            icon: const Icon(Icons.lock_outline),
            title: '修改密码',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _buildListTile(
            icon: const Icon(Icons.key_outlined),
            title: '账号安全中心',
            onTap: () => _showSecurityCenterDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('播放设置'),
          _buildListTile(
            icon: const Icon(Icons.play_circle_outline),
            title: '播放设置',
            subtitle: '播放器库、弹幕、画质等',
            onTap: () => context.push(Routes.playerSetting),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('数据模块'),
          _buildListTile(
            icon: const Icon(Icons.data_object),
            title: '数据管理',
            subtitle: '导入/导出 JSON 数据',
            onTap: () => context.push(Routes.dataSetting),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('通用设置'),
          _buildListTile(
            icon: const Icon(Icons.language_outlined),
            title: '语言',
            subtitle: '简体中文',
            onTap: () => _showLanguageDialog(context),
          ),
          _buildListTile(
            icon: const Icon(Icons.palette_outlined),
            title: '主题',
            subtitle: '跟随系统',
            onTap: () => _showThemeDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('关于'),
          _buildListTile(
            icon: const Icon(Icons.info_outline),
            title: '关于我们',
            onTap: () => _showAboutDialog(context),
          ),
          _buildListTile(
            icon: const Icon(Icons.help_outline),
            title: '帮助与反馈',
            onTap: () => _showHelpDialog(context),
          ),
          _buildListTile(
            icon: const Icon(Icons.share_outlined),
            title: '分享应用',
            onTap: () => _showShareDialog(context),
          ),
          const SizedBox(height: 16),
          if (auth.isLogin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: () => _showLogoutDialog(context, auth),
                child: const Text('退出登录'),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('个人资料'),
        content: const Text('个人资料设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: const Text('修改密码功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSecurityCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('账号安全中心'),
        content: const Text('账号安全中心功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('简体中文')),
            ListTile(title: Text('English')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('跟随系统')),
            ListTile(title: Text('浅色模式')),
            ListTile(title: Text('深色模式')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于我们'),
        content: const Text('Flutter Bili v1.0.0\n\n一款基于 Flutter 的哔哩哔哩客户端'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与反馈'),
        content: const Text('帮助与反馈功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享应用'),
        content: const Text('分享功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthS auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              auth.clearCredentials();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required Widget icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}