import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'recommend_page.dart';

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
    const Center(child: Text('搜索')),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '首页',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: '搜索',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    
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
                  leading: auth.isLogin 
                      ? const _UserLeading() 
                      : const _LoginButton(),
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
            // 窄屏布局：内容 + 底部导航栏
            return body;
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
}

/// 已登录用户头像
class _UserLeading extends StatelessWidget {
  const _UserLeading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          SizedBox(height: 4),
          Text(
            '已登录',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// 未登录登录按钮
class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            tooltip: '登录',
          ),
          const Text(
            '未登录',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
