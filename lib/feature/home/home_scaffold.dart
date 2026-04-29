import 'package:flutter/material.dart';
import 'package:flutter_bili/core/routes.dart';
import 'package:flutter_bili/feature/dynamic/dynamic_page_view.dart';
import 'package:flutter_bili/feature/home/recommend_page.dart';
import 'package:flutter_bili/feature/mine/mine_page.dart';
import 'package:flutter_bili/service/auth_s.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

  // 创建页面实例并保持它们的状态
  late final List<Widget> _pages = [
    const RecommendPage(),
    const DynamicPageView(),
    const MinePage(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '首页',
    ),
    NavigationDestination(
      icon: Icon(Icons.motion_photos_on_outlined),
      selectedIcon: Icon(Icons.motion_photos_on),
      label: '动态',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthS>();
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          
          // 页面内容
          final body = IndexedStack(
            index: _selectedIndex,
            children: _pages,
          );
          
          if (isWide) {
            // 宽屏布局：左侧 NavigationRail + 右侧内容
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildUserAvatar(auth),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => context.push(Routes.search),
                        tooltip: '搜索',
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => context.push(Routes.message),
                        tooltip: '消息',
                      ),
                    ],
                  ),
                  destinations: _destinations.map((d) {
                    return NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon ?? d.icon,
                      label: Text(d.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            );
          } else {
            // 窄屏布局：顶部栏 + 内容 + 底部导航栏
            return Column(
              children: [
                // 顶部栏
                if (_selectedIndex == 0) _buildTopBar(auth),
                Expanded(child: body),
              ],
            );
          }
        },
      ),
      // 底部导航栏只在窄屏时显示
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) return const SizedBox.shrink();
          
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            items: _destinations.map((d) {
              return BottomNavigationBarItem(
                icon: d.icon,
                activeIcon: d.selectedIcon ?? d.icon,
                label: d.label,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// 顶部栏（仅窄屏首页显示）
  Widget _buildTopBar(AuthS auth) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _buildUserAvatar(auth),
      ),
      title: GestureDetector(
        onTap: () => context.push(Routes.search),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '搜索',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push(Routes.message),
          tooltip: '消息',
        ),
      ],
    );
  }

  /// 用户头像
  Widget _buildUserAvatar(AuthS auth) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 2); // 跳转到我的页面
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: auth.isLogin
            ? const Icon(Icons.person, size: 20)
            : const Icon(Icons.person_outline, size: 20),
      ),
    );
  }
}
