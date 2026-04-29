import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/service/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
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
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.lock_outline),
            title: '修改密码',
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.key_outlined),
            title: '账号安全中心',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSectionTitle('播放设置'),
          _buildListTile(
            icon: const Icon(Icons.video_settings_outlined),
            title: '播放设置',
            subtitle: '视频播放相关设置',
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.subtitles_outlined),
            title: '弹幕设置',
            subtitle: '调整弹幕显示效果',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSectionTitle('通用设置'),
          _buildListTile(
            icon: const Icon(Icons.language_outlined),
            title: '语言',
            subtitle: '简体中文',
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.palette_outlined),
            title: '主题',
            subtitle: '跟随系统',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSectionTitle('关于'),
          _buildListTile(
            icon: const Icon(Icons.info_outline),
            title: '关于我们',
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.help_outline),
            title: '帮助与反馈',
            onTap: () {},
          ),
          _buildListTile(
            icon: const Icon(Icons.share_outlined),
            title: '分享应用',
            onTap: () {},
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
                onPressed: () => auth.clearCredentials(),
                child: const Text('退出登录'),
              ),
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

  Widget _buildDivider() {
    return const Divider(height: 1);
  }
}