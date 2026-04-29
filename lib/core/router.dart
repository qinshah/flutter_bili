import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_scaffold.dart';
import '../features/login/login_page.dart';
import '../features/message/message_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/data_settings_page.dart';
import '../features/settings/player_settings_page.dart';
import '../features/settings/settings_page.dart';
import '../features/video/video_detail_page.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScaffold(),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: Routes.message,
      builder: (context, state) => const MessagePage(),
    ),
    GoRoute(
      path: Routes.video,
      builder: (context, state) {
        final bvid = state.extra as String? ?? '';
        return VideoDetailPage(bvid: bvid);
      },
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'player',
          builder: (context, state) => const PlayerSettingsPage(),
        ),
        GoRoute(
          path: 'data',
          builder: (context, state) => const DataSettingsPage(),
        ),
      ],
    ),
  ],
);