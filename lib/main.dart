import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/service/storage_service.dart';
import 'app/http/auth_interceptor.dart';
import 'home/home_scaffold.dart';
import 'login/login_page.dart';
import 'message/message_page.dart';
import 'search/search_page.dart';
import 'video/video_detail_page.dart';
import 'app/service/auth_service.dart';
import 'app/service/dynamics_service.dart';
import 'app/service/recommend_service.dart';
import 'app/service/video_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  MediaKit.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  final authService = AuthService();
  authService.loadFromStorage();

  final videoService = VideoService();
  final recommendService = RecommendService();
  final dynamicsService = DynamicsService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<VideoService>.value(value: videoService),
        ChangeNotifierProvider<RecommendService>.value(value: recommendService),
        ChangeNotifierProvider<DynamicsService>.value(value: dynamicsService),
      ],
      child: const BiliApp(),
    ),
  );
}

class BiliApp extends StatelessWidget {
  const BiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFB7299),
      ),
      initialRoute: '/home',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomeScaffold(),
        '/search': (_) => const SearchPage(),
        '/message': (_) => const MessagePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/video') {
          final bvid = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => VideoDetailPage(bvid: bvid),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
