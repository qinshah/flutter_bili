import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bili/core/router.dart';
import 'package:flutter_bili/features/dynamic/dynamic_page_vm.dart';
import 'package:flutter_bili/features/home/recommend_vm.dart';
import 'package:flutter_bili/features/video/video_page_vm.dart';
import 'package:flutter_bili/service/auth_service.dart';
import 'package:flutter_bili/service/media_service.dart';
import 'package:flutter_bili/service/storage_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await StorageService.init();
  Future.delayed(
    const Duration(seconds: 5),
    AuthService.i.loadLocalCredentials,
  );
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
        ChangeNotifierProvider<MediaService>.value(value: MediaService.i),
        ChangeNotifierProvider<AuthService>.value(value: AuthService.i),
        ChangeNotifierProvider<VideoPageVm>.value(value: VideoPageVm.i),
        ChangeNotifierProvider<RecommendVm>.value(
          value: RecommendVm.i,
        ),
        ChangeNotifierProvider<DynamicPageVm>.value(
          value: DynamicPageVm.i,
        ),
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
