import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bili/core/router.dart';
import 'package:flutter_bili/feature/dynamic/dynamic_page_vm.dart';
import 'package:flutter_bili/feature/home/recommend_vm.dart';
import 'package:flutter_bili/feature/video/video_page_vm.dart';
import 'package:flutter_bili/service/auth_s.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageS.init();
  MediaS.initLib();
  Future.delayed(
    const Duration(seconds: 5),
    AuthS.i.loadLocalCredentials,
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
        ChangeNotifierProvider<MediaS>.value(value: MediaS.i),
        ChangeNotifierProvider<AuthS>.value(value: AuthS.i),
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
