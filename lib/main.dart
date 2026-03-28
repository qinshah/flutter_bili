import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app_storage.dart';
import 'http/auth_interceptor.dart';
import 'pages/home/home_scaffold.dart';
import 'pages/login/login_page.dart';
import 'pages/video/video_detail_page.dart';
import 'services/auth_service.dart';
import 'services/recommend_service.dart';
import 'services/video_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppStorage.init();
  MediaKit.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  final authService = AuthService();
  authService.loadFromStorage();

  final videoService = VideoService();
  final recommendService = RecommendService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<VideoService>.value(value: videoService),
        ChangeNotifierProvider<RecommendService>.value(value: recommendService),
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
