import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
    this.leading,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  /// Optional leading widget shown above the NavigationRail (wide layout only).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        if (isWide) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: leading,
            destinations: destinations.map((d) {
              return NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        items: destinations.map((d) {
          return BottomNavigationBarItem(
            icon: d.icon,
            activeIcon: d.selectedIcon ?? d.icon,
            label: d.label,
          );
        }).toList(),
      ),
    );
  }
}
