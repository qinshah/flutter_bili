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
  MediaKit.ensureInitialized();
  await StorageService.init();
  // 在鸿蒙不使用try包裹会白屏，即使loadLocalCredentials没有出错
  try {
    AuthService.i.loadLocalCredentials();
  } catch (e) {
    debugPrint('加载本地凭证失败: $e');
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  runApp(const BiliApp());
}

class BiliApp extends StatelessWidget {
  const BiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: AuthService.i),
        ChangeNotifierProvider<VideoService>.value(value: VideoService.i),
        ChangeNotifierProvider<RecommendService>.value(
          value: RecommendService.i,
        ),
        ChangeNotifierProvider<DynamicsService>.value(value: DynamicsService.i),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFB7299),
        ),
      ),
    );
  }
}
