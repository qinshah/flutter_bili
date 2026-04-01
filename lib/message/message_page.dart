import 'package:flutter/material.dart';

/// 消息页面
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // 三个快捷入口
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  context,
                  Icons.chat_bubble,
                  '收到回复',
                  Colors.green,
                ),
                _buildQuickAction(
                  context,
                  Icons.thumb_up,
                  '收到喜欢',
                  Colors.pink,
                ),
                _buildQuickAction(
                  context,
                  Icons.person_add,
                  '新增粉丝',
                  Colors.blue,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // 消息列表
          _buildMessageItem(
            theme,
            '哔哩哔哩智能机',
            '登录操作通知',
            '1小时前',
            hasUnread: true,
          ),
          _buildMessageItem(
            theme,
            '系统通知',
            '《哔哩哔哩隐私政策》修订通知',
            '3月16日',
          ),
          _buildMessageItem(
            theme,
            '罗さん不太酷',
            '[分享] 谁懂一觉醒来发现wzxq是我同学的救赎...',
            '1月25日',
          ),
          _buildMessageItem(
            theme,
            '星星喵',
            '[自动回复] 感谢关注 我向你敬礼啦 salute[藏猫]',
            '2025年5月26日',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    ThemeData theme,
    String name,
    String message,
    String time, {
    bool hasUnread = false,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: const Icon(Icons.person),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        // TODO: 打开消息详情
      },
    );
  }
}
