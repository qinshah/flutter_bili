import 'package:flutter/material.dart';
import 'package:flutter_bili/module/404/not_found_pv.dart';
import 'package:flutter_bili/module/video/full_screen_video_v.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../module/home/home_scaffold.dart';
import '../module/login/login_page.dart';
import '../module/message/message_page.dart';
import '../module/search/search_page.dart';
import '../module/setting/data_settings_page.dart';
import '../module/setting/player_settings_page.dart';
import '../module/setting/settings_page.dart';
import '../module/video/video_page_v.dart';
import 'routes.dart';

final router = GoRouter(
  initialLocation: Routes.home,
  redirect: (context, state) {
    debugPrint(state.fullPath);
    return null;
  },
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
        final bvid = state.extra as String?;
        if (bvid == null || bvid.isEmpty) return NotFoundPV('错误bvid：$bvid');
        return ChangeNotifierProvider(
          create: (BuildContext context) {
            return VideoPageVm(bvid: bvid);
          },
          child: const VideoPageV(),
        );
      },
      routes: [
        GoRoute(
          path: 'fullscreen',
          builder: (context, state) {
            final vm = state.extra as VideoPageVm?;
            if (vm == null) return const NotFoundPV('缺失VideoPageVm');
            return ChangeNotifierProvider.value(
              value: vm,
              child: const FullScreenVideoV(),
            );
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
