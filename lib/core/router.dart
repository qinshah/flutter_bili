import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/full_screen_video_v.dart';
import 'package:go_router/go_router.dart';

import '../module/home/home_scaffold.dart';
import '../module/login/login_page.dart';
import '../module/message/message_page.dart';
import '../module/search/search_page.dart';
import '../module/setting/data_settings_page.dart';
import '../module/setting/player_settings_page.dart';
import '../module/setting/settings_page.dart';
import '../module/video/video_page_v.dart';
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
        return VideoPageV(bvid: bvid);
      },
      routes: [
        GoRoute(
          path: 'fullscreen',
          builder: (context, state) {
            final bvid = state.extra as String? ?? '';
            return FullScreenVideoV(bvid: bvid);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.setting,
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
