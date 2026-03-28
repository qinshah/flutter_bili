import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/adaptive_scaffold.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

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

  Widget get _body {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('首页'));
      case 1:
        return const Center(child: Text('搜索'));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        return AdaptiveScaffold(
          selectedIndex: _selectedIndex,
          destinations: _destinations,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          body: _body,
          leading: auth.isLogin ? const _UserLeading() : null,
        );
      },
    );
  }
}

/// Shown in NavigationRail leading area when the user is logged in.
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
