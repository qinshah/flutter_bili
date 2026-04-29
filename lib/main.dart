import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/service/auth_service.dart';
import 'app/service/dynamics_service.dart';
import 'app/service/recommend_service.dart';
import 'app/service/storage_service.dart';
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
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFB7299),
      ),
    );
  }
}