import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../home/home_scaffold.dart';
import '../login/login_page.dart';
import '../message/message_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../video/video_detail_page.dart';
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
    ),
  ],
);