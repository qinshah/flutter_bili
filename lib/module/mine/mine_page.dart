import 'package:flutter/material.dart';
import 'package:flutter_bili/route/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../service/auth_s.dart';

/// 我的页面
class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final auth = context.watch<AuthS>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: 扫一扫
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(Routes.setting);
            },
          ),
        ],
      ),
      body: auth.isLogin
          ? _buildLoggedInContent(theme, auth)
          : _buildLoginPrompt(theme),
    );
  }

  /// 未登录状态
  Widget _buildLoginPrompt(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '登录后查看更多内容',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.push(Routes.login);
            },
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }

  /// 已登录状态
  Widget _buildLoggedInContent(ThemeData theme, AuthS auth) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 用户信息区域
        _buildUserInfoSection(theme),
        const SizedBox(height: 8),

        // 我的大会员
        _buildVipSection(theme),
        const SizedBox(height: 8),

        // 功能入口（离线缓存、历史记录、我的收藏、稍后再看）
        _buildQuickActions(theme),
        const SizedBox(height: 8),

        // 创作中心
        _buildCreatorCenter(theme),
        const SizedBox(height: 8),

        // 我的服务
        _buildMyServices(theme),
        const SizedBox(height: 24),
        // 切换账号
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: () => context.push(Routes.login),
            child: const Text('切换账号'),
          ),
        ),
        const SizedBox(height: 10),
        // 退出登录按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: () => _showLogoutDialog(auth),
            child: const Text('退出登录'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 用户信息区域
  Widget _buildUserInfoSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 头像和用户名
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: const Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'bili_9481667069',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '正式会员',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'B币: 0    硬币: 182',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // TODO: 跳转空间设置
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 动态、关注、粉丝
          Row(
            children: [
              Expanded(
                child: _buildStatItem('1', '动态', () {
                  // TODO: 跳转动态
                }),
              ),
              Container(width: 1, height: 40, color: theme.dividerColor),
              Expanded(
                child: _buildStatItem('3', '关注', () {
                  // TODO: 跳转关注
                }),
              ),
              Container(width: 1, height: 40, color: theme.dividerColor),
              Expanded(
                child: _buildStatItem('1', '粉丝', () {
                  // TODO: 跳转粉丝
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 我的大会员
  Widget _buildVipSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.pink.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: Colors.pink.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '我的大会员',
              style: TextStyle(
                color: Colors.pink.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '热播内容看不停',
            style: TextStyle(fontSize: 12, color: Colors.pink.shade700),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.pink.shade700, size: 20),
        ],
      ),
    );
  }

  /// 快捷功能
  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _ActionItem(Icons.download_outlined, '离线缓存', () {}),
      _ActionItem(Icons.history, '历史记录', () {}),
      _ActionItem(Icons.star_outline, '我的收藏', () {}),
      _ActionItem(Icons.watch_later_outlined, '稍后再看', () {}),
    ];

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return InkWell(
            onTap: action.onTap,
            child: Column(
              children: [
                Icon(action.icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(action.label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 创作中心
  Widget _buildCreatorCenter(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '创作中心',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              FilledButton.tonal(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('发布'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildServiceItem(Icons.article_outlined, '稿件管理'),
              _buildServiceItem(Icons.chat_bubble_outline, '互动管理'),
              _buildServiceItem(Icons.people_outline, '粉丝管理'),
              _buildServiceItem(Icons.bar_chart, '数据中心'),
            ],
          ),
        ],
      ),
    );
  }

  /// 我的服务
  Widget _buildMyServices(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的服务',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildServiceItem(Icons.school_outlined, '我的课程'),
              _buildServiceItem(Icons.video_library_outlined, '看视频免流量'),
              _buildServiceItem(Icons.card_giftcard_outlined, '我的钱包'),
              _buildServiceItem(Icons.bolt_outlined, '充电'),
              _buildServiceItem(Icons.checkroom_outlined, '个性装扮'),
              _buildServiceItem(Icons.live_tv_outlined, '主播中心'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(AuthS auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await auth.logout();
    }
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionItem(this.icon, this.label, this.onTap);
}
